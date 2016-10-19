module Tako
  module ActiveRecordExt
    module Association
      def current_shard
        owner.current_shard
      end

      def self.included(mod)
        mod.extend(ShardedMethods)
        mod.sharded_methods :target_scope
      end
    end
  end
end

ActiveRecord::Associations::Association.class_eval do
  include Tako::ActiveRecordExt::Association
end
