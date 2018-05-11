require 'spec_helper'

describe 'ActiveRecord::Base.shard' do
  describe "creating records" do
    subject do
      ModelA.shard(:shard01).create(id: 1)
      ModelA.shard(:shard02).create(id: 2)
      ModelA.create(id: 3)
    end

    it "id: 1 records will be persisted at shard01, id: 2 at shard02, id: 3 at default" do
      aggregate_failures do
        subject

        expect(ModelA.shard(:shard01).find_by(id: 1)).to_not be_nil
        expect(ModelA.shard(:shard02).find_by(id: 1)).to be_nil
        expect(ModelA.find_by(id: 1)).to be_nil

        expect(ModelA.shard(:shard01).find_by(id: 2)).to be_nil
        expect(ModelA.shard(:shard02).find_by(id: 2)).to_not be_nil
        expect(ModelA.find_by(id: 2)).to be_nil

        expect(ModelA.shard(:shard01).find_by(id: 3)).to be_nil
        expect(ModelA.shard(:shard02).find_by(id: 3)).to be_nil
        expect(ModelA.find_by(id: 3)).to_not be_nil
      end
    end
  end

  describe "shard block" do
    subject do
      ModelA.shard(:shard01) do
        ModelA.create(id: 3)
      end

      ModelA.shard(:shard02) do
        ModelA.create(id: 4)
      end

      ModelA.create(id: 5)
    end

    it "id: 3 records will be persisted at shard01, id: 4 at shard02, id: 5 at default" do
      aggregate_failures do
        subject

        expect(ModelA.shard(:shard01).find_by(id: 3)).to_not be_nil
        expect(ModelA.shard(:shard02).find_by(id: 3)).to be_nil
        expect(ModelA.find_by(id: 3)).to be_nil

        expect(ModelA.shard(:shard01).find_by(id: 4)).to be_nil
        expect(ModelA.shard(:shard02).find_by(id: 4)).to_not be_nil
        expect(ModelA.find_by(id: 4)).to be_nil

        expect(ModelA.shard(:shard01).find_by(id: 5)).to be_nil
        expect(ModelA.shard(:shard02).find_by(id: 5)).to be_nil
        expect(ModelA.find_by(id: 5)).to_not be_nil
      end
    end
  end

  describe "transaction" do
    subject do
      ModelA.shard(:shard01).transaction do
        ModelA.create(id: 3)
      end

      ModelA.shard(:shard02).transaction do
        ModelA.create(id: 4)
      end

      ModelA.transaction do
        ModelA.create(id: 5)
      end
    end

    it "id: 3 records will be persisted at shard01, id: 4 at shard02, id: 5 at default" do
      aggregate_failures do
        subject

        expect(ModelA.shard(:shard01).find_by(id: 3)).to_not be_nil
        expect(ModelA.shard(:shard02).find_by(id: 3)).to be_nil
        expect(ModelA.find_by(id: 3)).to be_nil

        expect(ModelA.shard(:shard01).find_by(id: 4)).to be_nil
        expect(ModelA.shard(:shard02).find_by(id: 4)).to_not be_nil
        expect(ModelA.find_by(id: 4)).to be_nil

        expect(ModelA.shard(:shard01).find_by(id: 5)).to be_nil
        expect(ModelA.shard(:shard02).find_by(id: 5)).to be_nil
        expect(ModelA.find_by(id: 5)).to_not be_nil
      end
    end
  end

  describe "where chain" do
    subject do
      ModelA.shard(:shard01).create(value1: 1, value2: "Hoge1")
      ModelA.shard(:shard01).create(value1: 1, value2: "Huga1")
      ModelA.shard(:shard01).create(value1: 2, value2: "Hoge2")
      ModelA.shard(:shard01).create(value1: 2, value2: "Huga2")

      ModelA.shard(:shard02).create(id: 1000, value1: 1, value2: "Hoge1")
      ModelA.shard(:shard02).create(id: 1001, value1: 1, value2: "Hoge1")
      ModelA.shard(:shard02).create(id: 1002, value1: 1, value2: "Hoge1")
      ModelA.shard(:shard02).create(id: 1003, value1: 1, value2: "Huga1")
      ModelA.shard(:shard02).create(id: 1004, value1: 2, value2: "Huga2")
      ModelA.shard(:shard02).create(id: 1005, value1: 2, value2: "Huga2")
    end

    it "where chain works" do
      aggregate_failures do
        subject

        expect(ModelA.shard(:shard01).where(value2: "Hoge1").where(value1: 1).first).to_not be_nil
        expect(ModelA.shard(:shard01).where(value2: "Hoge2").where(value1: 2).first).to_not be_nil
        expect(ModelA.shard(:shard01).where(value2: "Huga1").where(value1: 1).first).to_not be_nil
        expect(ModelA.shard(:shard01).where(value2: "Huga2").where(value1: 2).first).to_not be_nil
        expect(ModelA.shard(:shard01).where(value2: "Huga2").where(value1: 1).first).to be_nil

        # nest
        expect(Tako.shard(:shard01) { ModelA.shard(:shard02).where(value1: 1).limit(5).count }).to eq(4)

        # limit and offset
        expect(ModelA.shard(:shard02).where(value1: 1).limit(3).count).to eq(3)
        expect(ModelA.shard(:shard02).where(value1: 1).offset(2).count).to eq(2)

        # pluck
        expect(ModelA.shard(:shard02).where.not(value2: "Huga2").pluck(:value1)).to eq([1, 1, 1, 1])

        # first
        expect(ModelA.shard(:shard02).where(value1: 2).order(:id).first.id).to eq(1004)
        expect(ModelA.shard(:shard02).where(value1: 2).order(:id).last.id).to eq(1005)

        # find
        expect(ModelA.shard(:shard02).where(value1: 1).find(1000)).to_not be_nil
        expect(ModelA.shard(:shard02).where(value1: 1).find_by(value2: "Huga1")).to_not be_nil

        # calclate methods
        expect(ModelA.shard(:shard01).average(:value1)).to eq(1.5)
        expect(ModelA.shard(:shard02).average(:value1)).to eq(1.3333)

        # reload
        expect(ModelA.shard(:shard01).where(value2: "Huga2").where(value1: 1).reload.first).to be_nil
      end
    end
  end

  describe "force_shard" do
    subject do
      ForceShardRoot.shard(:shard01).create(id: 1)
      ForceShardRoot.shard(:shard02).create(id: 2)

      ForceShardA.shard(:shard01).create(force_shard_root_id: 1)
      ForceShardA.shard(:shard02).create(force_shard_root_id: 2)

      ForceShardB.shard(:shard01).create(force_shard_root_id: 1)
      b = ForceShardB.shard(:shard02).create(force_shard_root_id: 2)

      ForceShardB.sharded_class_method(3)
      b.sharded_method(4)
      # turn off for force sharding
      allow(ActiveRecord::Base).to receive(:force_shard?).and_return(false)
    end

    it "creates record with force shard" do
      aggregate_failures do
        subject

        expect(ForceShardRoot.shard(:shard01).find_by(id: 1)).to be_present
        expect(ForceShardRoot.shard(:shard01).find_by(id: 2)).to be_blank
        expect(ForceShardRoot.shard(:shard02).find_by(id: 1)).to be_blank
        expect(ForceShardRoot.shard(:shard02).find_by(id: 2)).to be_present

        expect(ForceShardA.shard(:shard01).find_by(force_shard_root_id: 1)).to be_present
        expect(ForceShardA.shard(:shard01).find_by(force_shard_root_id: 2)).to be_present
        expect(ForceShardA.shard(:shard02).find_by(force_shard_root_id: 1)).to be_blank
        expect(ForceShardA.shard(:shard02).find_by(force_shard_root_id: 2)).to be_blank

        expect(ForceShardB.shard(:shard01).find_by(force_shard_root_id: 1)).to be_blank
        expect(ForceShardB.shard(:shard01).find_by(force_shard_root_id: 2)).to be_blank
        expect(ForceShardB.shard(:shard01).find_by(force_shard_root_id: 3)).to be_blank
        expect(ForceShardB.shard(:shard01).find_by(force_shard_root_id: 4)).to be_blank
        expect(ForceShardB.shard(:shard02).find_by(force_shard_root_id: 1)).to be_present
        expect(ForceShardB.shard(:shard02).find_by(force_shard_root_id: 2)).to be_present
        expect(ForceShardB.shard(:shard02).find_by(force_shard_root_id: 3)).to be_present
        expect(ForceShardB.shard(:shard02).find_by(force_shard_root_id: 4)).to be_present
      end
    end
  end

  describe "has_many association" do
    it "works" do
      aggregate_failures do
        expect(User.shard(:shard01).find_by(id: 1)).to be_blank

        user = User.shard(:shard01).create(id: 1)

        expect(User.find_by(id: 1)).to be_blank
        expect(User.shard(:shard01).find_by(id: 1)).to be_present
        expect(User.shard(:shard02).find_by(id: 1)).to be_blank
        expect(user.logs).to be_blank
        expect(user.logs.count).to eq(0)
        expect(Log.shard(:shard01).find_by(id: 1)).to be_blank
        expect(Log.shard(:shard02).find_by(id: 2)).to be_blank
        expect(Log.shard(:shard01).new(id: 1).current_shard).to eq(:shard01)

        user.logs << Log.shard(:shard01).new(id: 1)
        user.logs << Log.shard(:shard02).new(id: 2)

        expect(user.logs).to be_present
        expect(user.logs.count).to eq(1)
        expect(Log.find_by(id: 1)).to be_blank
        expect(Log.shard(:shard01).find_by(id: 1)).to be_present
        expect(Log.shard(:shard02).find_by(id: 1)).to be_blank
        expect(Log.shard(:shard01).find_by(id: 2)).to be_blank
        expect(Log.shard(:shard02).find_by(id: 2)).to be_present

        Log.shard(:shard01).new(id: 2, user: user).save

        expect(Log.find_by(id: 2)).to be_blank
        expect(Log.shard(:shard01).find_by(id: 2)).to be_present
        expect(user.reload.logs.reload.count).to eq(2)
      end
    end
  end

  describe "has_one association" do
    it "works" do
      aggregate_failures do
        expect(User.shard(:shard01).find_by(id: 1)).to be_blank

        user = User.shard(:shard01).create(id: 1)

        # User(id: 1) should be persisted in shard01
        expect(User.find_by(id: 1)).to be_blank
        expect(User.shard(:shard01).find_by(id: 1)).to be_present
        expect(User.shard(:shard02).find_by(id: 1)).to be_blank
        expect(user.wallet).to be_blank

        user.build_wallet(id: 1)

        expect(user.wallet).to be_present
        expect(user.wallet).to_not be_persisted
        expect(user.wallet.current_shard).to eq(:shard01)
        expect(Wallet.find_by(id: 1)).to be_blank
        expect(Wallet.shard(:shard01).find_by(id: 1)).to be_blank
        expect(Wallet.shard(:shard02).find_by(id: 1)).to be_blank

        user.wallet.save

        expect(user.wallet).to be_persisted
        expect(Wallet.find_by(id: 1)).to be_blank
        expect(Wallet.shard(:shard01).find_by(id: 1)).to be_present
        expect(Wallet.shard(:shard02).find_by(id: 1)).to be_blank
        expect(user.reload.wallet.reload).to be_present
      end
    end

    it "works" do
      aggregate_failures do
        blog_shard1 = Blog.shard(:shard01).create(id: 1)

        expect(blog_shard1.author).to be_blank
        expect(Author.shard(:shard01).find_by(id: 1)).to be_blank

        blog_shard1.create_author(id: 1)

        expect(blog_shard1.author).to be_present
        expect(Author.shard(:shard01).find_by(id: 1)).to be_present

        blog_shard2 = Blog.shard(:shard02).create(id: 2)

        expect(blog_shard2.author).to be_blank
        author = blog_shard2.build_author(id: 2)

        expect(author).to_not be_persisted
        expect(author.current_shard).to eq(:shard02)

        author.save!

        expect(author).to be_persisted
        expect(Author.shard(:shard02).find_by(id: 2)).to be_present
      end
    end
  end

  describe "AssociationRelation" do
    it "works" do
      user = User.shard(:shard01).create(id: 1)

      expect(User.shard(:shard01).first).to eq(user)

      Log.shard(:shard01).create(number: 1, user: user)
      Log.shard(:shard01).create(number: 2, user: user)
      Log.shard(:shard01).create(number: 3, user: user)

      expect(Log.shard(:shard01).count).to eq(3)
      expect(Log.shard(:shard01).number_gteq(2).reload.count).to eq(2)
      expect(user.logs.count).to eq(3)
      expect(user.logs.number_gteq(3).count).to eq(1)
    end
  end

  describe "when ActiveRecord methods aliased" do
    before do
      ::ActiveRecord::Base.class_eval do
        alias_method :save_alias, :save

        def save(*args, &blk)
          if true
            save_alias(*args, &blk)
          end
        end
      end
    end

    it "works" do
      aggregate_failures do
        normal_model = ModelA.shard(:shard01).create(id: 1)
        normal_model.update_attributes(value1: 1)

        expect(normal_model).to be_persisted

        evil_model = SaveAlias.shard(:shard01).create(id: 1)
        evil_model.update_attributes(value1: 1)

        expect(evil_model).to be_persisted
      end
    end
  end

  describe "query chain method with block args" do
    it "works" do
      record = ModelA.shard(:shard01).find_or_initialize_by(id: 1) do |a|
        a.value1 = 1
      end
      expect(record.value1).to eq(1)
    end
  end
end
