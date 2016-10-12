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
      end
    end
  end

  describe "force_shard" do
    subject do
      User.shard(:shard01).create(id: 1)
      User.shard(:shard02).create(id: 2)

      Wallet.shard(:shard01).create(user_id: 1)
      Wallet.shard(:shard02).create(user_id: 2)

      Log.shard(:shard01).create(user_id: 1)
      log = Log.shard(:shard02).create(user_id: 2)

      Log.sharded_class_method(3)
      log.sharded_method(4)
      # turn off for force sharding
      allow(ActiveRecord::Base).to receive(:force_shard?).and_return(false)
    end

    it "creates record with force shard" do
      aggregate_failures do
        subject

        expect(User.shard(:shard01).find_by(id: 1)).to be_present
        expect(User.shard(:shard01).find_by(id: 2)).to be_blank
        expect(User.shard(:shard02).find_by(id: 1)).to be_blank
        expect(User.shard(:shard02).find_by(id: 2)).to be_present

        expect(Wallet.shard(:shard01).find_by(user_id: 1)).to be_present
        expect(Wallet.shard(:shard01).find_by(user_id: 2)).to be_present
        expect(Wallet.shard(:shard02).find_by(user_id: 1)).to be_blank
        expect(Wallet.shard(:shard02).find_by(user_id: 2)).to be_blank

        expect(Log.shard(:shard01).find_by(user_id: 1)).to be_blank
        expect(Log.shard(:shard01).find_by(user_id: 2)).to be_blank
        expect(Log.shard(:shard01).find_by(user_id: 3)).to be_blank
        expect(Log.shard(:shard01).find_by(user_id: 4)).to be_blank
        expect(Log.shard(:shard02).find_by(user_id: 1)).to be_present
        expect(Log.shard(:shard02).find_by(user_id: 2)).to be_present
        expect(Log.shard(:shard02).find_by(user_id: 3)).to be_present
        expect(Log.shard(:shard02).find_by(user_id: 4)).to be_present
      end
    end
  end

  describe "assosiations" do
    subject do
      Tako.shard(:shard01) do
        blog = Blog.create(id: 1)
        blog.author || blog.build_author.save!
        blog.articles << Article.new(id: 1)
        blog.articles << Article.new(id: 2)
        blog.articles << Article.new(id: 3)
      end

      blog = Blog.shard(:shard02).create(id: 2)
      blog.create_author
      blog.articles << Article.new(id: 4)
      blog.articles << Article.new(id: 5)
      blog.articles << Article.new(id: 6)
    end

    it "where chain works" do
      aggregate_failures do
        subject

        blog_shard1 = Blog.shard(:shard01).first
        expect(blog_shard1.author).to be_present
        expect(blog_shard1.author.blog_id).to eq(1)
        expect(blog_shard1.articles.pluck(:id)).to eq([1, 2, 3])

        blog_shard2 = Blog.shard(:shard02).first
        expect(blog_shard2.author).to be_present
        expect(blog_shard2.author.blog_id).to eq(2)
        expect(blog_shard2.articles.pluck(:id)).to eq([4, 5, 6])
      end
    end
  end
end
