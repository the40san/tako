$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'tako'

ENV["RAILS_ENV"] ||= 'test'
ENV['TAKO_CONFIG_FILE_PATH'] ||= "spec/config/shards.yml"

Dir[File.join(File.dirname(__FILE__), '../', "spec/support/**/*.rb")].each { |f| require f }
Dir[File.join(File.dirname(__FILE__), '../', "spec/active_record/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.before(:suite) do
    Tako.config[:test].values.each do |conf|
      ActiveRecord::Tasks::DatabaseTasks.drop(conf)
      ActiveRecord::Tasks::DatabaseTasks.create(conf)
    end

    Tako.load_connections_from_yaml

    Tako.shard(:shard01) do
      ActiveRecord::Migration.run(
        CreateModelA,
        CreateModelB
      )
    end

    Tako.shard(:shard02) do
      ActiveRecord::Migration.run(
        CreateModelA,
        CreateModelB
      )
    end

    database_yml_path = File.join(File.dirname(__FILE__), "config/database.yml")
    database_yml = YAML.load(ERB.new(File.read(database_yml_path)).result).with_indifferent_access[:test]
    ActiveRecord::Tasks::DatabaseTasks.drop(database_yml)
    ActiveRecord::Tasks::DatabaseTasks.create(database_yml)
    ActiveRecord::Base.establish_connection(database_yml)
    ActiveRecord::Migration.run(
      CreateModelA,
      CreateModelB
    )
  end

  config.before(:each) do
    ModelA.delete_all
    ModelB.delete_all
    ModelA.shard(:shard01).delete_all
    ModelB.shard(:shard01).delete_all
    ModelA.shard(:shard02).delete_all
    ModelB.shard(:shard02).delete_all
  end

  config.after(:each) do
    ModelA.delete_all
    ModelB.delete_all
    ModelA.shard(:shard01).delete_all
    ModelB.shard(:shard01).delete_all
    ModelA.shard(:shard02).delete_all
    ModelB.shard(:shard02).delete_all
  end
end
