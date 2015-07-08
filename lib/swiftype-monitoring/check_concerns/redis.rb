require 'redis'
require 'active_support/core_ext/hash'

module SwiftypeMonitoring
  module CheckConcerns
    module Redis

      #
      # Simple wrapper class for Redis connection that handles connection errors by exiting properly
      #
      class ConnectionWrapper
        attr_reader :check, :name, :config, :client

        def initialize(check, name, config)
          @check = check
          @name = name.to_s
          @config = config
          @client = ::Redis.new(config)

          # Make sure the connection is actually alive
          ping
        end

        def method_missing(method, *args, &block)
          client.send(method, *args, &block)
        rescue ::Redis::BaseError => e
          check.critical("Redis[#{name}] Error: #{e}")
        end
      end

      #---------------------------------------------------------------------------------------------
      # Returns redis connection config by name
      def redis_config_by_name(name)
        connections = swiftype_config['redis_connections'] || {}
        config = connections[name]
        critical("Unknown Redis connection: #{name}") unless config
        return config.symbolize_keys
      end

      #---------------------------------------------------------------------------------------------
      # Create a Redis connection
      def redis_connection(name)
        name = name.to_s
        config = redis_config_by_name(name)
        ConnectionWrapper.new(self, name, config)
      end

    end
  end
end
