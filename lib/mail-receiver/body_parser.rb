# Mail body context parser
module MailReceiver
  module BodyParser
    # might need: mail.body.split(‘—-Original Message-—‘)[0].reverse.split(‘nO’)[-1].reverse for Outlook
    def extract
      self.decoded_part.
      # Most providers start it off with that "On" date line.
      reverse.split(' nO')[-1].reverse.
      # Fancy sigs and sigs need to be discarded
      split(/^-*/).first.chomp.
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
