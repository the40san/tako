require 'erb'
require "tako/version"
require "tako/config"
require "tako/active_record_ext"
require "tako/repository"
require "tako/proxy_stack"
require "tako/proxy"
require "tako/query_chain"

module Tako
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

    def load_connections_from_yaml(shards_yml = Tako::Config.shards_yml)
      (shards_yml[:tako][Tako::Config.env] || []).each do |shard_name, conf|
        Tako::Repository.add(shard_name, conf)
      end
    end

    def config
      Tako::Config.shards_yml[:tako]
    end
  end
end

require 'active_record'

ActiveRecord::ConnectionHandling.class_eval do
  prepend Tako::ActiveRecordExt::ConnectionHandling::Prepend
end

ActiveRecord::Base.class_eval do
  extend Tako::ActiveRecordExt::Base::Extend
end
