module Tako
  class Repository
    class << self
      def proxy_configs
        @proxy_configs ||= {}
      end

      def proxy_classes
        @proxy_classes ||= {}
      end

      def clear
        proxy_classes.each do |shard_name, proxy_class|
          proxy_class.connection.disconnect!
          remove_const("TAKO_AR_CLASS_#{shard_name.upcase}")
        end
        proxy_configs.clear
        proxy_classes.clear
      end

      def add(shard_name, conf)
        shard_name = shard_name.to_sym
        return if proxy_configs[shard_name]

        temporary_class = Class.new(ActiveRecord::Base)
        const_set("TAKO_AR_CLASS_#{shard_name.upcase}", temporary_class)
        temporary_class.establish_connection(conf)

        proxy_classes[shard_name] = temporary_class
        proxy_configs[shard_name] = conf
      end

      def create_proxy(shard_name)
        Proxy.new(shard_name, proxy_classes[shard_name.to_sym].connection_without_tako)
      end

      def shard_names
        proxy_configs.keys
      end
    end
  end
end
