module Tako
  module ActiveRecordExt
    module CollectionAssociation
      SHARDED_METHODS = [
        :reader,
        :writer,
        :ids_reader,
        :ids_writer,
        :create,
        :create!,
        :build,
        :any?,
        :count,
        :empty?,
        :first,
        :include?,
        :last,
        :length,
        :load_target,
        :many?,
        :reload,
        :size,
        :select,
        :uniq,
      ] & ActiveRecord::Associations::CollectionAssociation.public_instance_methods

      def self.included(mod)
        mod.extend(ShardedMethods)
        mod.sharded_methods *SHARDED_METHODS
      end
    end
  end
end

ActiveRecord::Associations::CollectionAssociation.class_eval do
  include Tako::ActiveRecordExt::CollectionAssociation
end
