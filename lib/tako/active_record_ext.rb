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

    module Association
      module Overrides
        def reader(force_reload = false)
          return super unless owner.current_shard
          Tako.shard(owner.current_shard) do
            create_query_chain(super)
          end
        end

        def writer(records)
          return super unless owner.current_shard
          Tako.shard(owner.current_shard) do
            create_query_chain(super)
          end
        end

        private

        def create_query_chain(base_object)
          return if base_object.nil?
          Tako::QueryChain.new(
            Tako::Repository.shard(owner.current_shard),
            base_object
          )
        end
      end
    end
  end
end
