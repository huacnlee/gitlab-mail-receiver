require 'active_support/core_ext/hash'
require 'rack'

module MailReceiver
  module Encoder
    class << self
      def encode(hash)
        hash.to_query
      end

      def decode(query)
       Rack::Utils.parse_query(query).deep_symbolize_keys
      end
    end
  end
end
