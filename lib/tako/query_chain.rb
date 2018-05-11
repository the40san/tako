module Tako
  class QueryChain
    attr_reader :proxy
    attr_reader :base_object

    def initialize(proxy, base_object)
      @proxy = proxy
      @base_object = base_object
    end

    def method_missing(method, *args, &block)
      @proxy.with_shard do
        result = if block_given?
                    base_object.send(method, *args, &block)
                  else
                    base_object.send(method, *args)
                  end

        if chain_available?(result)
          @base_object = result
          return self
        end

        result
      end
    end

    def shard(shard_name)
      new(
        Tako::Repository.create_proxy(shard_name),
        self
      )
    end

    private

    def chain_available?(obj)
      [
        ::ActiveRecord::Relation,
        ::ActiveRecord::QueryMethods::WhereChain
      ].any? { |anc| obj.is_a?(anc) }
    end
  end
end
