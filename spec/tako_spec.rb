require 'spec_helper'

describe Tako do
  it 'has a version number' do
    expect(Tako::VERSION).not_to be nil
  end

  describe ".shard" do
    subject do
      Tako.shard(:shard01) do
        ModelA.create(id: 3)
      end

      Tako.shard(:shard02) do
        ModelA.create(id: 4)
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
      end
    end
  end

  describe ".config" do
    subject { Tako.config }

    it "returns config without :tako header" do
      expect(subject).to eq(
        {
          test: {
            shard01: {
              adapter: "mysql2",
              encoding: "utf8",
              charset: "utf8",
              collation: "utf8_unicode_ci",
              reconnect: false,
              username: ENV['MYSQL_USER_NAME'] || "root",
              password: ENV['MYSQL_ROOT_PASSWORD'],
              host:     ENV['MYSQL_HOST'] || "localhost",
              port:     ENV['MYSQL_PORT'] || 3306,
              database: "tako_test_shard1"
            },
            shard02: {
              adapter: "mysql2",
              encoding: "utf8",
              charset: "utf8",
              collation: "utf8_unicode_ci",
              reconnect: false,
              username: ENV['MYSQL_USER_NAME'] || "root",
              password: ENV['MYSQL_ROOT_PASSWORD'],
              host:     ENV['MYSQL_HOST'] || "localhost",
              port:     ENV['MYSQL_PORT'] || 3306,
              database: "tako_test_shard2"
            }
          }
        }.with_indifferent_access
      )
    end
  end

  # in MultiShardExecution
  describe ".shard_names" do
    subject { Tako.shard_names }

    it "returns all shard names" do
      expect(subject).to eq(
        [
          :shard01,
          :shard02
        ]
      )
    end
  end

  describe ".with_all_shards" do
    subject do
      Tako.with_all_shards do
        ModelA.create(id: 1)
      end
    end

    it "creates a record at all shards" do
      subject

      expect(ModelA.shard(:shard01).find_by(id: 1)).to_not be_nil
      expect(ModelA.shard(:shard02).find_by(id: 1)).to_not be_nil
      expect(ModelA.find_by(id: 1)).to be_nil
    end
  end

  describe "transaction in block" do
    subject do
      Tako.shard(:shard01) do
        ModelA.transaction do
          ModelA.create(id: 1)
        end
      end
    end

    it "creates a record at all shards" do
      subject

      expect(ModelA.shard(:shard01).find_by(id: 1)).to_not be_nil
      expect(ModelA.shard(:shard02).find_by(id: 1)).to be_nil
      expect(ModelA.find_by(id: 1)).to be_nil
    end
  end

  describe "method has yield" do
    subject do
      Tako.shard(:shard01) do
        ModelA.new(id: 1).yield_method do |rec|
          rec.save
        end
        ModelA.create(id: 2)
      end
    end

    it "creates a record at all shards" do
      subject

      expect(ModelA.shard(:shard01).find_by(id: 1)).to_not be_nil
      expect(ModelA.shard(:shard01).find_by(id: 2)).to_not be_nil
      expect(ModelA.shard(:shard02).find_by(id: 1)).to be_nil
      expect(ModelA.shard(:shard02).find_by(id: 2)).to be_nil
      expect(ModelA.find_by(id: 1)).to be_nil
      expect(ModelA.find_by(id: 2)).to be_nil
    end
  end

  describe "load_connections_from_yaml" do
    it "clears old connections" do
      old_object_ids = [
        ActiveRecord::Base.shard(:shard01).connection.object_id,
        ActiveRecord::Base.shard(:shard02).connection.object_id
      ]

      Tako.load_connections_from_yaml

      new_object_ids = [
        ActiveRecord::Base.shard(:shard01).connection.object_id,
        ActiveRecord::Base.shard(:shard02).connection.object_id
      ]

      expect(new_object_ids).to_not eq(old_object_ids)
    end
  end
end
