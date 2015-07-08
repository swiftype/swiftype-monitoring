require 'erb'

module SwiftypeMonitoring
  module NotificationConcerns
    module Env
      # Include rendering helpers
      include ERB::Util

      def read_env(name)
        ENV[name] or raise "Missing environment variable: #{name}"
      end

      def contact_email_address
        read_env('NAGIOS_CONTACTEMAIL')
      end

      def alert_type
        read_env('NAGIOS_NOTIFICATIONTYPE')
      end

      def acknowledgement?
        alert_type == 'ACKNOWLEDGEMENT'
      end

      def alert_number
        read_env('NAGIOS_SERVICENOTIFICATIONNUMBER').to_i
      end

      def service_name
        read_env('NAGIOS_SERVICEDESC')
      end

      def service_status
        read_env('NAGIOS_SERVICESTATE')
      end

      def service_duration
        read_env('NAGIOS_SERVICEDURATION')
      end

      def service_output
        read_env('NAGIOS_SERVICEOUTPUT')
      end

      def service_long_output
        read_env('NAGIOS_LONGSERVICEOUTPUT')
      end

      def alert_timestamp
        Time.parse(read_env('NAGIOS_LONGDATETIME'))
      end

      def alert_timestamp_short
        alert_timestamp.strftime('%Y-%m-%d %H:%M:%S')
      end

      def ack_comment
        read_env('NAGIOS_SERVICEACKCOMMENT')
      end

      def alert_action
        return 'ACKNOWLEDGED' if alert_type == 'ACKNOWLEDGEMENT'
        return 'RECOVERED' if alert_type == 'RECOVERY'
        return 'TRIGGERED'
      end

    end
  end
end
