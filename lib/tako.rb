require 'erb'
require "tako/version"
require "tako/config"
require "tako/active_record_ext"
require "tako/repository"
require "tako/proxy_stack"
require "tako/proxy"
require "tako/query_chain"
require "tako/multi_shard_execution"

module Tako
  extend MultiShardExecution

  class << self
    def shard(shard_name)
      if block_given?
        Tako::Repository.shard(shard_name).in_proxy do
          yield
        end
      else
        raise "gimme a block!"
      end
    end

    def load_connections_from_yaml
      (config[env] || []).each do |shard_name, conf|
        Tako::Repository.add(shard_name, conf)
      end
    end

    def config
      Tako::Config.shards_yml[:tako]
    end

    def env
      Tako::Config.env
    end
  end
end

require 'active_record'
require 'tako/active_record_ext/sharded_methods'
require 'tako/active_record_ext/connection_handling'
require 'tako/active_record_ext/base'
require 'tako/active_record_ext/association'
require 'tako/active_record_ext/collection_association'
require 'tako/active_record_ext/singular_association'
require 'tako/active_record_ext/collection_proxy'
require 'tako/active_record_ext/association_relation'
require 'tako/active_record_ext/log_subscriber'

require 'tako/railtie' if defined?(::Rails)
