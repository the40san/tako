module Tako
  class ProxyStack
    class << self
      def top
        @current
      end

      def in_piles(proxy)
        proxy.base ||= @current
        @current = proxy

        yield
      ensure
        @current = @current.base
      end
    end
  end
end
