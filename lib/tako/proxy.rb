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
      log("[Tako] Getting in :#{@shard_name}")
      Tako::ProxyStack.in_piles(self) do
        yield
      end.tap do
        log("[Tako] Getting out :#{@shard_name}", YELLOW)
      end
    end

    private

    CLEAR   = "\e[0m"
    GREEN   = "\e[32m"
    YELLOW  = "\e[33m"

    def log(progname = nil, color = GREEN)
      if defined?(::Rails)
        Rails.logger.debug "#{color}#{progname}#{CLEAR}"
      end
    end
  end
end
