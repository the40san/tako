module Tako
  module ActiveRecordExt
    module Base
      module ClassMethods
        def shard(shard_name)
          if block_given?
            Tako.shard(shard_name) do
              yield
            end
          else
            Tako::QueryChain.new(
              Tako::Repository.shard(shard_name),
              self
            )
          end
        end

        def force_shard(shard_name)
          @force_shard = shard_name
        end

        def force_shard?
          @force_shard.present?
        end
      end

      module InstanceMethods
        attr_accessor :current_shard

        def self.included(mod)
          mod.extend(ShardedMethods)
          mod.sharded_methods :update_attribute,
                              :update_attributes,
                              :update_attributes!,
                              :reload,
                              :delete,
                              :destroy,
                              :touch,
                              :update_column,
                              :save,
                              :save!

          mod.class_eval do
            after_initialize :set_current_shard

            private

              def set_current_shard
                @current_shard = ::Tako::ProxyStack.top.try(:shard_name)
              end
          end
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  extend Tako::ActiveRecordExt::Base::ClassMethods
  include Tako::ActiveRecordExt::Base::InstanceMethods
end
