module Tako
  class Proxy
    attr_reader :shard_name
    attr_reader :connection
    attr_accessor :base

    def initialize(shard_name, connection, base)
      @shard_name = shard_name
      @connection = connection
      @base = base
    end

    def in_proxy
      Tako::ProxyStack.in_piles(self) do
        yield
      end
    end
  end
end
