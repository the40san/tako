module Tako
  class ProxyStack
    class << self
      def top
        @current
      end

      def with_shard(proxy)
        previous ||= @current
        @current = proxy

        yield
      ensure
        @current = previous
      end
    end
  end
end
