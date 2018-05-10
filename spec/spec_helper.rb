$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'tako'
require 'pry'

ENV["RAILS_ENV"] ||= 'test'
ENV['TAKO_CONFIG_FILE_PATH'] ||= "spec/config/shards.yml"

Dir[File.join(File.dirname(__FILE__), '../', "spec/support/**/*.rb")].each { |f| require f }
Dir[File.join(File.dirname(__FILE__), '../', "spec/active_record/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.before(:suite) do
    migration_classes = [CreateAllTables]

    Tako.config[:test].values.each do |conf|
      ActiveRecord::Tasks::DatabaseTasks.drop(conf)
      ActiveRecord::Tasks::DatabaseTasks.create(conf)
    end

    Tako.load_connections_from_yaml

    Tako.shard(:shard01) do
      ActiveRecord::Migration.run(*migration_classes)
    end

    Tako.shard(:shard02) do
      ActiveRecord::Migration.run(*migration_classes)
    end

    database_yml_path = File.join(File.dirname(__FILE__), "config/database.yml")
    database_yml = YAML.load(ERB.new(File.read(database_yml_path)).result).with_indifferent_access[:test]
    ActiveRecord::Tasks::DatabaseTasks.drop(database_yml)
    ActiveRecord::Tasks::DatabaseTasks.create(database_yml)
    ActiveRecord::Base.establish_connection(database_yml)
    ActiveRecord::Migration.run(*migration_classes)
  end

  config.before(:each) do
    [
      ModelA,
      ModelB,
      ForceShardRoot,
      ForceShardA,
      ForceShardB,
      User,
      Wallet,
      Log,
      Blog,
      Article,
      Author,
      Character,
      Skill,
      CharacterSkill,
      SaveAlias
    ].each do |klass|
      klass.delete_all
      klass.shard(:shard01).delete_all
      klass.shard(:shard02).delete_all
    end
  end

  config.after(:each) do
    [
      ModelA,
      ModelB,
      ForceShardRoot,
      ForceShardA,
      ForceShardB,
      User,
      Wallet,
      Log,
      Blog,
      Article,
      Author,
      Character,
      Skill,
      CharacterSkill,
      SaveAlias
    ].each do |klass|
      klass.delete_all
      klass.shard(:shard01).delete_all
      klass.shard(:shard02).delete_all
    end
  end
end
