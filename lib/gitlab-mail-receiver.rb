require_relative './mail-receiver/body_parser'
require_relative './mail-receiver/receiver'
require_relative './mail-receiver/reply_to'
require "mailman"
require 'active_support/core_ext'

module MailmanConfig
  extend ActiveSupport::Concern

  included do
    attr_accessor :sender
  end
end

Mailman::Configuration.send(:include, MailmanConfig)

module MailReceiver
  def self.configure(&block)
    Mailman.config.instance_exec(&block)
  end
end
