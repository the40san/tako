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
end
