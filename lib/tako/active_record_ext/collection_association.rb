module Tako
  module ActiveRecordExt
    module CollectionAssociation
      def self.included(mod)
        mod.extend(ShardedMethods)
        mod.sharded_methods :reader,
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
                            :uniq
      end
    end
  end
end

ActiveRecord::Associations::CollectionAssociation.class_eval do
  include Tako::ActiveRecordExt::CollectionAssociation
end
