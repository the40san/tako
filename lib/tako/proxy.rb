module Tako
  class Proxy
    attr_reader :shard_name
    attr_reader :connection

    def initialize(shard_name, connection)
      @shard_name = shard_name
      @connection = connection
    end

    def with_shard
      Tako::ProxyStack.with_shard(self) do
        yield
      end
    end
  end
end
