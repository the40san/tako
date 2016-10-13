module Tako
  module ActiveRecordExt
    module ConnectionHandling
      module Overrides
        def connection
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
  end
end
