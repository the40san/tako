module Tako
  module ActiveRecordExt
    module ConnectionHandling
      module Overrides
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
          mod.class_eval do
            after_initialize :set_current_shard

            private

              def set_current_shard
                @current_shard = ::Tako::ProxyStack.top.try(:shard_name)
              end
          end
        end
      end

      module Overrides
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
        end
      end
    end

    module LogSubscriber
      module Overrides
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

    module ShardedMethods
      def sharded_methods(*method_names)
        method_names.each do |method_name|
          define_method(:"#{method_name}_with_tako") do |*params, &block|
            if current_shard
              ::Tako.shard(current_shard) { send(:"#{method_name}_without_tako",*params, &block) }
            else
              send(:"#{method_name}_without_tako",*params, &block)
            end
          end
          send(:alias_method, :"#{method_name}_without_tako", method_name)
          send(:alias_method, method_name, :"#{method_name}_with_tako")
        end
      end
    end

    module Association
      module Overrides
        def current_shard
          owner.current_shard
        end

        def self.included(mod)
          mod.extend(ShardedMethods)
          mod.sharded_methods :target_scope
        end
      end
    end

    module CollectionAssociation
      module Overrides
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

    module SingularAssociation
      module Overrides
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

    module CollectionProxy
      module Overrides
        def self.included(mod)
          mod.extend(ShardedMethods)
          mod.sharded_methods :any?,
                              :build,
                              :count,
                              :create,
                              :create!,
                              :concat,
                              :delete,
                              :delete_all,
                              :destroy,
                              :destroy_all,
                              :empty?,
                              :find,
                              :first,
                              :include?,
                              :last,
                              :length,
                              :many?,
                              :pluck,
                              :replace,
                              :select,
                              :size,
                              :sum,
                              :to_a,
                              :uniq
        end

        def current_shard
          @association.owner.current_shard
        end
      end
    end

    module AssociationRelation
      module Overrides
        def self.included(mod)
          mod.extend(ShardedMethods)
          mod.sharded_methods :any?,
                              :build,
                              :count,
                              :create,
                              :create!,
                              :delete,
                              :delete_all,
                              :destroy,
                              :destroy_all,
                              :empty?,
                              :find,
                              :first,
                              :include?,
                              :last,
                              :length,
                              :many?,
                              :pluck,
                              :select,
                              :size,
                              :sum,
                              :to_a,
                              :uniq
        end

        def current_shard
          @association.owner.current_shard
        end
      end
    end
  end
end
