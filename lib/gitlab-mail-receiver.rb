require_relative './mail-receiver/encoder'
require_relative './mail-receiver/body_parser'
require_relative './mail-receiver/receiver'
require_relative './mail-receiver/reply_to'

require 'mailman'
require 'email_reply_parser'
require 'active_support/core_ext'

# Extend Mailman config to add sender attribute
module MailmanConfig
  extend ActiveSupport::Concern

  included do
    attr_accessor :sender
  end
end

Mailman::Configuration.send(:include, MailmanConfig)

# MailReceiver
module MailReceiver
  def self.config
    Mailman.config
  end

  def self.configure(&block)
    Mailman.config.instance_exec(&block)
  end
end
