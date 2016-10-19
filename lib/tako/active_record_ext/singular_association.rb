module Tako
  module ActiveRecordExt
    module SingularAssociation
      def self.included(mod)
        mod.extend(ShardedMethods)
        mod.sharded_methods :reader,
                            :writer,
                            :create,
                            :create!,
                            :build
      end
    end
  end
end

ActiveRecord::Associations::SingularAssociation.class_eval do
  include Tako::ActiveRecordExt::SingularAssociation
end
