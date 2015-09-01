require 'mailman'
require 'json'

module MailReceiver
  module ReplyTo
    def mail_new_thread(model, headers = {}, &block)
      # Mail receiver
      headers[:reply_to] = reply_to_address(model)

      mail(headers, &block)
    end

    def mail_answer_thread(model, headers = {}, &block)
      if headers[:subject]
        headers[:subject].prepend('Re: ')
      end

      # Mail receiver
      headers[:reply_to] = reply_to_address(model)

      mail(headers, &block)
    end

    protected
    def reply_to_address(model)
      hash = convert_able(model)
      return default_email_reply_to if hash.blank?
      return default_email_reply_to if @project.blank?


      hash.merge!({ p: @project.path_with_namespace })

      suffix = Encoder.encode(hash)

      Mailman.config.sender.sub('@', "+#{suffix}@")
    end

    def default_email_reply_to
      Gitlab.config.gitlab.email_reply_to
    end

    def convert_able(model)
      res = { id: model.iid }
      if defined?(@note)
        # gitlab/app/mailers/emails/notes.rb 里面会声明 @note
        res.merge!({ n: @note.id })
      end

      if model.class.name == 'Issue'
        res.merge({ t: 'i' })
        return res
      end

      if model.class.name == 'MergeRequest'
        res.merge({ t: 't' })
        return res
      end

      return nil
    end
  end
end
