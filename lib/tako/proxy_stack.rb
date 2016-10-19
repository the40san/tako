module Tako
  class ProxyStack
    class << self
      def top
        @current
      end

      def in_piles(proxy)
        previous ||= @current
        @current = proxy

        yield
      ensure
        @current = previous
      end
    end
  end
end
