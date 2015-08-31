require "rubygems"
require "bundler/setup"
require_relative './gitlab-mail-receiver'

app_root = ENV['GITLAB_ROOT']

begin
  rails_env = ::File.join(app_root, './config/environment')
  require rails_env
rescue => e
  puts "You need run this command under GitLab root."
  return
end

require_relative './gitlab-mail-receiver'

logger = Logger.new(File.join(app_root, 'log/gitlab-mail-receiver.log'))
Mailman.config.logger = logger
Mailman.config.rails_root = app_root

logger.info "Starting Mailman ..."
Mailman::Application.run do
  to '%user%+%suffix%@%host%' do
    @receiver = MailReceiver::Receiver.new(message, logger: logger)
    @receiver.process!
  end
end
