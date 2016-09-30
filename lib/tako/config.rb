module Tako
  class Config
    class << self
      def shards_yml
        YAML.load(ERB.new(File.read(yml_path)).result).with_indifferent_access
      end

      def env
        defined?(::Rails.env) ? Rails.env : (ENV['RAILS_ENV'] || :default)
      end

      private

      def yml_path
        File.join(directory, ENV['TAKO_CONFIG_FILE_PATH'] || "config/shards.yml")
      end

      def directory
        defined?(::Rails.root) ? Rails.root.to_s : Dir.pwd
      end
    end
  end
end
