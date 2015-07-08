require 'swiftype-monitoring'
require 'swiftype-monitoring/check_concerns'

require 'sensu-plugin/check/cli'

module SwiftypeMonitoring
  class Check < Sensu::Plugin::Check::CLI
    # Include specific concerns
    include SwiftypeMonitoring::CheckConcerns::Config
    include SwiftypeMonitoring::CheckConcerns::Formatting
    include SwiftypeMonitoring::CheckConcerns::Kestrel
    include SwiftypeMonitoring::CheckConcerns::MySQL
    include SwiftypeMonitoring::CheckConcerns::Redis
    include SwiftypeMonitoring::CheckConcerns::ES

    #-----------------------------------------------------------------------------------------------
    # Convenient option method wrappers
    def self.warning_option(desc, default)
      integer_option(:warning, :short => '-w VALUE', :long => '--warning=VALUE', :description => desc, :default => default)
    end

    def self.critical_option(desc, default)
      integer_option(:critical, :short => '-c VALUE', :long => '--critical=VALUE', :description => desc, :default => default)
    end

    def self.integer_option(name, params)
      params[:proc] = proc { |a| a.to_i }
      option(name, params)
    end

    def self.boolean_option(name, params)
      params[:boolean] = true
      option(name, params)
    end

    #-----------------------------------------------------------------------------------------------
    def run
      puts "ERROR: Please define run method in your check class!"
      exit(1)
    end

    # Redefine output method to support additional parameter (message)
    def output(status_message, additional_info = nil)
      status_message ||= @message
      output = "#{@status}"
      output << ": #{status_message}" if status_message
      output << "\n#{additional_info}" if additional_info
      puts output
    end
  end
end
