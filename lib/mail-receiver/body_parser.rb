# Mail body context parser
module MailReceiver
  module BodyParser
    def extract
      self.decoded_part.
      # Most providers start it off with that "On" date line.
      # reverse.split(' nO')[-1].reverse.
      # Fancy sigs and sigs need to be discarded
      chomp.
      # Strip leading and trailing whitespace
      strip
    end

    def decoded_part
      self.part.decoded
    end

    def part
      self.mail.multipart? ? self.mail.parts.first.body : self.mail.body
    end
  end
end
