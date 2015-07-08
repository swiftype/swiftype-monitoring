require 'yaml'
require 'erb'

module SwiftypeMonitoring
  class Config
    attr_reader :config_file

    def initialize(config_file)
      @config_file = config_file
    end

    def data
      load_config! unless @config
      return @config
    end

    def load_config!
      # Check the file
      unless File.readable?(config_file)
        raise ArgumentError, "Could not find config file: #{config_file}"
      end

      # Load and parse config file
      raw_config = File.read(config_file)
      erb_config = ERB.new(raw_config).result
      @config = YAML.load(erb_config) || {}
    end

  end
end
