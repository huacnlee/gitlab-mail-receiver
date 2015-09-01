require_relative './daemon'
require 'thor'

module MailReceiver
  class CLI < Thor
    include Thor::Actions

    map '-v' => :version
    map "s" => :start
    class_option :root, type: :string, default: './'

    option :daemon, type: :boolean, aliases: ['d'], default: false
    desc "start", "Start Daemon"
    def start
      MailReceiver::Daemon.init(options) do
        begin
          rails_env = ::File.expand_path('./config/environment', options[:root])
          require rails_env
        rescue => e
          puts "You need run this command under GitLab root."
          return
        end

        Mailman.config.logger = Logger.new($stdout)
        Mailman.config.rails_root = options[:root]

        Mailman.config.logger.info "Starting gitlab-mail-receiver..."
        Mailman::Application.run do
          to '%user%+%suffix%@%host%' do
            @receiver = MailReceiver::Receiver.new(message, logger: Mailman.config.logger)
            @receiver.process!
          end
        end
      end
      MailReceiver::Daemon.start_process
    end

    desc "stop", "Stop Daemon"
    def stop
      MailReceiver::Daemon.init(options)
      MailReceiver::Daemon.stop_process
    end

    desc "restart", "Restart Daemon"
    def restart
      MailReceiver::Daemon.init(options)
      MailReceiver::Daemon.restart_process
    end

    desc "version", "Show version"
    def version
      puts "gitlab-mail-receiver #{MailReceiver.version}"
    end
  end
end
