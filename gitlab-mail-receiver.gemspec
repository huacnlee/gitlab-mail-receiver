require File.expand_path('../lib/mail-receiver/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "gitlab-mail-receiver"
  s.version     = MailReceiver.version
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jason Lee"]
  s.email       = ["huacnlee@gmail.com"]
  s.homepage    = "http://github.com/huacnlee/gitlab-mail-receiver"
  s.summary     = "Allow your GitLab receive mails to create Issue comment"
  s.description = "The way of allow your GitLab support Email receive and parse the email content, and find Issue/MergeRequest to create reply."
  s.license     = 'MIT'
  s.required_rubygems_version = ">= 1.3.6"

  s.add_runtime_dependency("mailman", '~> 0.7.3')
  s.add_runtime_dependency("activesupport", ">= 4.0")
  s.add_runtime_dependency("rack", '>= 1.0')
  s.add_runtime_dependency("thor", ">= 0.17.0")
  s.add_runtime_dependency("email_reply_parser", "~> 0.5.8")

  s.bindir = 'bin'
  s.executables << 'gitlab-mail-receiver'
  s.files        = Dir.glob("lib/**/*") + %w(README.md LICENSE)
  s.require_path = 'lib'
end
