require 'tako'

namespace :db do
  namespace :tako do
    task :load_config do
      Tako.load_connections_from_yaml
    end

    task :check_protected_environments => [:environment, :load_config] do
      if ActiveRecord::Tasks::DatabaseTasks.respond_to?(:check_protected_environments!)
        ActiveRecord::Tasks::DatabaseTasks.check_protected_environments!
      end
    end

    task :create do
      (Tako.config[Tako.env] || []).values.each do |conf|
        ActiveRecord::Tasks::DatabaseTasks.create(conf)
      end
    end

    task :migrate => [:environment] do
      paths = ActiveRecord::Tasks::DatabaseTasks.migrations_paths
      # load all migration files
      paths.each do |path|
        Dir[File.join(path, "*")].each {|f| require f }
      end

      Tako.with_all_shards do
        version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
        revert = !!ENV["DOWN_MIGRATION"]

        migrations = if version
          [
            ActiveRecord::Migrator.migrations(paths).find {|proxy| proxy.version == version }.name.constantize
          ]
        else
          ActiveRecord::Migrator.migrations(paths).map(&:name).map(&:constantize)
        end

        ActiveRecord::Migration.run(*migrations, revert: revert)
      end
    end

    namespace :migrate do
      task :up => ['db:tako:migrate']

      task :down  => [:environment] do
        ENV["DOWN_MIGRATION"] = "y"
        Rake::Task['db:tako:migrate'].invoke
      end
    end

    task :drop => [:load_config, :check_protected_environments] do
      (Tako.config[Tako.env] || []).values.each do |conf|
        ActiveRecord::Tasks::DatabaseTasks.drop(conf)
      end
    end
  end
end
