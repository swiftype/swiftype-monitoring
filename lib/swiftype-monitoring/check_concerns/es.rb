require 'elasticsearch'

module SwiftypeMonitoring
  module CheckConcerns
    module ES

      #
      # Simple wrapper class for ES connection that handles connection errors by exiting properly
      #
      class ConnectionWrapper
        attr_reader :check, :name, :config, :client

        def initialize(check, name, config)
          @check = check
          @name = name.to_s
          # use staging port by default
          @config = {
            :host => "#{config[:host]}:#{config[:port].to_s}",
          }
          @client = ::Elasticsearch::Client.new @config
          # Make sure the connection is actually alive
          ping!
        end

        # Performs a blocks of code with proper error handling for ES errors
        def handling_es_errors
          raise "Needs a block!" unless block_given?
          yield
        rescue Faraday::ConnectionFailed => e
          check.critical("Error while talking to ElasticSearch cluster (#{name}): #{e}")
        end

        # Test ES connection
        def ping!
          handling_es_errors do
            client.cluster.health
          end
        end

        # Returns cluster-level statistics
        def cluster_health
          handling_es_errors do
            stats = client.cluster.health
            if stats['cluster_name'] != name
              check.critical("Cluster name used for current port doesn't match.
                              Provided: #{name}, returned by ES: #{stats['cluster_name']}")
            end
            stats
          end
        end

        def shards_info
          handling_es_errors do
            shards = client.count["_shards"]
            return {
              :shards => {
                :total => shards["total"].to_i,
                :successful => shards["successful"].to_i,
                :failed => shards["failed"].to_i
              }
            }
          end
        end
      end

      #---------------------------------------------------------------------------------------------
      # Returns ES connection config by name
      def es_config_by_name(name)
        connections = swiftype_config['elasticsearch_connections'] || {}
        config = connections[name]
        critical("Unknown ES connection: #{name}") unless config
        return config.symbolize_keys
      end

      #---------------------------------------------------------------------------------------------
      # Create a ES cluster connection
      def es_connection(name)
        name = name.to_s
        config = es_config_by_name(name)
        ConnectionWrapper.new(self, name, config)
      end

    end
  end
end
