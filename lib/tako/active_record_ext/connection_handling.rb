module Tako
  module ActiveRecordExt
    module ConnectionHandling
      def connection
        return Tako::Repository.shard(@force_shard).connection if force_shard?
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
  prepend Tako::ActiveRecordExt::ConnectionHandling
end
