Gem::Specification.new do |s|
  s.name        = "gitlab-mail-receiver"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jason Lee"]
  s.email       = ["huacnlee@gmail.com"]
  s.homepage    = "http://github.com/huacnlee/gitlab-mail-receiver"
  s.summary     = "Allow your GitLab to receive mails to create Issue comment"
  s.description = "Allow your GitLab to receive mails to create Issue comment."
  s.license     = 'MIT'
  s.required_rubygems_version = ">= 1.3.6"

  s.add_runtime_dependency("mailman", '~> 0.7.3')
  s.add_runtime_dependency("daemons", '>= 1.0.0')
  s.add_runtime_dependency("actionpack", ">= 4.0")
  s.add_runtime_dependency("activesupport", ">= 4.0")

  s.bindir = 'bin'
  s.files        = Dir.glob("lib/**/*") + %w(README.md LICENSE)
  s.require_path = 'lib'
end
