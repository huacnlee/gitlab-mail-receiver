module MailReceiver
  # Mail body context parser
  module BodyParser
    def extract
      EmailReplyParser.read(part.to_s)
        .fragments.map(&:to_s)
        .join("\n").rstrip
        .force_encoding('utf-8')
    end

    def part
      mail.multipart? ? mail.parts.first.body : mail.body
    end
  end
end
