module Tako
  class QueryChain
    attr_reader :proxy
    attr_reader :base_object

    def initialize(proxy, base_object)
      @proxy = proxy
      @base_object = base_object
    end

    def method_missing(method, *args)
      @proxy.in_proxy do
        if block_given?
          base_object.send(method, *args) do
            yield
          end
        else
          base_object.send(method, *args)
        end
      end
    end

    def shard(shard_name)
      new(
        Tako::Repository.shard(shard_name),
        self
      )
    end
  end
end
