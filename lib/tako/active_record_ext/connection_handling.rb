module Tako
  module ActiveRecordExt
    module ConnectionHandling
      def connection
        return Tako::Repository.create_proxy(@force_shard).connection if force_shard?
        if Tako::ProxyStack.top
          Tako::ProxyStack.top.connection
        else
          super
        end
      end
    end
  end
end

ActiveRecord::ConnectionHandling.class_eval do
  alias_method :connection_without_tako, :connection
  prepend Tako::ActiveRecordExt::ConnectionHandling
end
