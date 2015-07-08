require 'swiftype-monitoring/config'

module SwiftypeMonitoring
  module CheckConcerns
    module Config

      def swiftype_config_reader
        # FIXME: this assumes the script is locates in scripts/swiftype, need to make it more robust
        scripts_dir = File.dirname($PROGRAM_NAME)
        root_dir = File.expand_path('../..', scripts_dir)
        config_file = File.expand_path("config/config.yml", root_dir)

        SwiftypeMonitoring::Config.new(config_file)
      end

      # Returns a hash representing our configuration file
      def swiftype_config
        swiftype_config_reader.data
      end

    end
  end
end
