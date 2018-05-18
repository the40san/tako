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
        ActiveRecord::SchemaMigration.create_table

        version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
        revert = !!ENV["DOWN_MIGRATION"]

        migrations = if defined?(ActiveRecord::MigrationContext)
          ActiveRecord::MigrationContext.new(paths).migrations
        else
          ActiveRecord::Migrator.migrations(paths)
        end
        migrations.select! {|proxy| proxy.version == version } if version
        all_schema_migration_versions = ActiveRecord::SchemaMigration.pluck(:version)
        migrations = migrations.reject {|proxy| all_schema_migration_versions.include?(proxy.version.to_s) }
        migrations.each do |proxy|
          ActiveRecord::Migration.run(proxy.name.constantize, revert: revert)
          if revert
            ActiveRecord::SchemaMigration.where(:version => proxy.version.to_s).delete_all
          else
            ActiveRecord::SchemaMigration.create!(:version => proxy.version.to_s)
          end
        end

        if defined?(ActiveRecord::InternalMetadata)
          ActiveRecord::InternalMetadata.create_table
          ActiveRecord::InternalMetadata[:environment] = if defined?(ActiveRecord::MigrationContext)
            ActiveRecord::MigrationContext.new(paths).current_environment
          else
            ActiveRecord::Migrator.current_environment
          end
        end
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
