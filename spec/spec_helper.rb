require 'rubygems'
require 'ostruct'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require "gitlab-mail-receiver"

# Fake models
class User < OpenStruct
  class << self
    def find_by_any_email(email)
      return nil if email.blank?
      return { email: email }
    end
  end
end

class Project < OpenStruct
  class << self
    def find_with_namespace(slug)
      raise 'not found project' if slug.blank?
      return { slug: slug }
    end
  end
end

class Note < OpenStruct; end
class Issue < OpenStruct; end
class MergeRequest < OpenStruct; end
class Other < OpenStruct; end

MailReceiver.configure do
  self.sender = 'reply@gitlab.com'
  self.poll_interval = 5
  self.imap = {
    server: 'imap.gitlab-mail.com',
    port: 993,
    ssl: true,
    username: 'reply@gitlab.com',
    password: '123456'
  }
end
