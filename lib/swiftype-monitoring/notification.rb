require 'swiftype-monitoring'
require 'swiftype-monitoring/notification_concerns'
require 'swiftype-monitoring/check_concerns'

require 'mixlib/cli'
require 'logger'
require 'active_support/core_ext/integer/inflections'

module SwiftypeMonitoring
  class Notification
    # Make it a CLI script
    include Mixlib::CLI

    # Include specific concerns
    include SwiftypeMonitoring::CheckConcerns::Config
    include SwiftypeMonitoring::NotificationConcerns::Env

    def run
      parse_options
      send
    end

    def send
      raise NotImplementedEror, "Please define the #send method on your notification class!"
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def render_template(template_name, template_type = nil)
      # FIXME: this assumes the script is locates in scripts/swiftype, need to make it more robust
      scripts_dir = File.dirname($PROGRAM_NAME)
      root_dir = File.expand_path('../..', scripts_dir)
      templates_dir = File.join(root_dir, 'config', 'notification_templates')

      # Read template
      file_name = [ template_name, template_type, 'erb' ].compact.join('.')
      template_file = File.join(templates_dir, file_name)
      template = File.read(template_file)

      # Render the thing
      ERB.new(template, nil, '-').result(binding)
    end
  end
end
