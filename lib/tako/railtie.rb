if defined?(::Rails)
  module Tako
    class Railtie < Rails::Railtie
      rake_tasks do
        load "tako/railties/databases.rake"
      end

      initializer "tako.initialize_database" do
        ActiveSupport.on_load(:active_record) do
          Tako.load_connections_from_yaml
        end
      end
    end
  end
end
