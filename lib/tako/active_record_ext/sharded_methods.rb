module Tako
  module ActiveRecordExt
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
  end
end
