module Tako
  class Config
    class << self
      def shards_yml
        yml = YAML.load(ERB.new(File.read(yml_path)).result).with_indifferent_access

        (yml[:tako] || {}).each do |env, shard|
          shard.each do |name, conf|
            url = conf.delete("url")
            conf.merge!(extract_url_to_hash(url)) if url
          end
        end

        yml
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

      def extract_url_to_hash(url)
        ActiveRecord::ConnectionAdapters::ConnectionSpecification::ConnectionUrlResolver.new(url).to_hash
      end
    end
  end
end
