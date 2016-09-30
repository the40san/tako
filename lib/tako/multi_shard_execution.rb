module Tako
  module MultiShardExecution
    def with_all_shards
      shard_names.each do |shard_name|
        shard(shard_name) do
          yield
        end
      end
    end

    def shard_names
      Tako::Repository.shard_names
    end
  end
end
