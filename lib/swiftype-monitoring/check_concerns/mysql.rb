require 'mysql2'
require 'ostruct'

module SwiftypeMonitoring
  module CheckConcerns
    module MySQL

      #
      # Simple wrapper class for MySQL connection that handles connection errors by exiting properly
      #
      class ConnectionWrapper
        attr_reader :check, :name, :config, :client

        def initialize(check, name, config)
          @check = check
          @name = name.to_s
          @config = config
          @client = Mysql2::Client.new(config)

          # Make sure the connection is actually alive
          ping!
        end

        #-------------------------------------------------------------------------------------------
        # Test MySQL connection
        def ping!
          client.ping
        rescue => e
          check.critical("Error while talking to MySQL(#{name}): #{e}")
        end

        #-------------------------------------------------------------------------------------------
        # Run a query and return the result
        def query(*args)
          client.query(*args)
        rescue Mysql2::Error => e
          check.critical("MySQL(#{name}) Error: #{e}", "Query: #{args.inspect}")
        end

        #-------------------------------------------------------------------------------------------
        # Run a query and return a single row
        def fetch_row(sql)
          # Run the query
          results = query(sql)

          # Check result counts
          if results.count == 0
            check.critical("Expected to receive a single row, but result set is empty", "SQL: #{sql}")
          end
          if results.count > 1
            check.critical("Expected to receive a single row, but result has #{results.count} lines", "SQL: #{sql}")
          end

          # Get the first and only row
          return results.first
        end

        #-------------------------------------------------------------------------------------------
        # Run a query and return a single value result
        def fetch_value(sql)
          # Get the row
          row = fetch_row(sql)

          # Check field count
          if row.count > 1
            check.critical("Expected to receive a single value, but result has more than one field", "SQL: #{sql}\nResult: #{row.inspect}")
          end

          return row.values.first
        end

        # Given a table, id_column, and optional timestamp_column, perform a
        # query to find the oldest row.
        #
        # args - the Hash of arguments
        #        :table            - the String name of the table (required)
        #        :id_columns       - an Array of the String names of the ID
        #                            columns (required)
        #        :timestamp_column - the String name of the timestamp column to
        #                            diff with NOW() (default: 'created_at')
        #
        # Returns an lag info that responds `lag` and each of the id_columns
        # or nil if there are no matching rows.
        def fetch_lag_info(args)
          table = args.fetch(:table)
          id_columns = args.fetch(:id_columns)
          time_column = args[:timestamp_column] || 'created_at'

          raise "id_columns must not be empty" if id_columns.empty?

          sql = "SELECT #{id_columns.join(', ')}, TIMESTAMPDIFF(SECOND, #{time_column}, NOW()) AS lag
             FROM #{table} ORDER BY #{time_column} ASC LIMIT 1"

          results = query(sql)

          return nil if results.count == 0

          oldest_row = results.first
          lag_info = OpenStruct.new(:lag => oldest_row['lag'].to_i)
          id_columns.each do |id_column|
            lag_info.send("#{id_column}=".to_sym, oldest_row[id_column])
          end

          lag_info
        end
      end

      #---------------------------------------------------------------------------------------------
      # Returns mysql connection config by name
      def mysql_config_by_name(name)
        connections = swiftype_config['mysql_connections'] || {}
        critical("Unknown MySQL connection: #{name}") unless connections[name]
        return connections[name]
      end

      #---------------------------------------------------------------------------------------------
      # Create a mysql connection
      def mysql_connection(name)
        name = name.to_s
        config = mysql_config_by_name(name)
        ConnectionWrapper.new(self, name, config)
      end

    end
  end
end
