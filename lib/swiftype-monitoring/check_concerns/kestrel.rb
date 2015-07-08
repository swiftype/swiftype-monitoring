require 'kjess'
require 'active_support/core_ext/hash'

module SwiftypeMonitoring
  module CheckConcerns
    module Kestrel

      #
      # Simple wrapper class for Kestrel connection that handles connection errors by exiting properly
      #
      class ConnectionWrapper
        attr_reader :check, :name, :config, :client

        def initialize(check, name, config)
          @check = check
          @name = name.to_s

          @config = {
            :connect_timeout => 10,
            :write_timeout => 10,
            :read_timeout => 10
          }.merge(config)

          @client = ::KJess::Client.new(@config)

          # Make sure the connection is actually alive
          ping!
        end

        # Performs a blocks of code with proper error handling for kestrel errors
        def handling_kestrel_errors
          raise "Needs a block!" unless block_given?
          yield
        rescue KJess::Error => e
          check.critical("Error while talking to Kestrel(#{name}): #{e}")
        end

        # Test Kestrel connection
        def ping!
          handling_kestrel_errors do
            client.ping
          end
        end

        # Returns broker-level and queue-level statistics
        def broker_stats
          handling_kestrel_errors do
            client.stats!
          end
        end

        # Returns queue-level statistics for all queues
        def queue_stats
          broker_stats["queues"]
        end

        # Return queue
        def queue_size(queue_name)
          queue_info = queue_stats[queue_name]
          queue_info ? queue_info["items"].to_i : nil
        end
      end

      #---------------------------------------------------------------------------------------------
      # Returns kestrel connection config by name
      def kestrel_config_by_name(name)
        connections = swiftype_config['kestrel_brokers'] || {}
        config = connections[name]
        critical("Unknown Kestrel broker: #{name}") unless config
        return config.symbolize_keys
      end

      #---------------------------------------------------------------------------------------------
      # Create a Kestrel broker connection
      def kestrel_connection(name)
        name = name.to_s
        config = kestrel_config_by_name(name)
        ConnectionWrapper.new(self, name, config)
      end

    end
  end
end
