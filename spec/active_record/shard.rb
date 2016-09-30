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
end
