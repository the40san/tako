module Tako
  module ActiveRecordExt
    module LogSubscriber
      CLEAR   = "\e[0m"
      GREEN   = "\e[32m"

      def debug(msg)
        current_shard = ::Tako::ProxyStack.top.try(:shard_name)

        if current_shard
          super("#{GREEN}[Shard: #{current_shard}]#{CLEAR}" + msg)
        else
          super
        end
      end
    end
  end
end

ActiveRecord::LogSubscriber.class_eval do
  prepend Tako::ActiveRecordExt::LogSubscriber
end
