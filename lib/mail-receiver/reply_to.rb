require 'mailman'

module MailReceiver
  module ReplyTo
    def mail_new_thread(model, headers = {}, &block)
      headers['Message-ID'] = message_id(model)
      headers['X-GitLab-Project'] = "#{@project.name} | " if @project

      # Mail receiver
      headers[:reply_to] = reply_to_address(model)

      mail(headers, &block)
    end

    def mail_answer_thread(model, headers = {}, &block)
      headers['In-Reply-To'] = message_id(model)
      headers['References'] = message_id(model)
      headers['X-GitLab-Project'] = "#{@project.name} | " if @project

      if headers[:subject]
        headers[:subject].prepend('Re: ')
      end

      # Mail receiver
      headers[:reply_to] = reply_to_address(model)

      mail(headers, &block)
    end

    protected
    def reply_to_address(model)
      able_path = convert_able_path(model)
      return default_email_reply_to if able_path.blank?
      return default_email_reply_to if @project.blank?

      slug = "#{@project.path_with_namespace}#{able_path}"

      Mailman.config.sender.sub('@', "+#{slug}@")
    end



    def default_email_reply_to
      Gitlab.config.gitlab.email_reply_to
    end

    def convert_able_path(model)
      if model.class.name == 'Issue'
        return "##{model.iid}"
      end

      if model.class.name == 'MergeRequest'
        return "!#{model.iid}"
      end


      if model.class.name == 'Note'
        if model.noteable_type == 'Issue' && model.noteable
          return "##{model.noteable.iid}"
        end

        if model.noteable_type == 'MergeRequest' && model.noteable
          return "!#{model.noteable.iid}"
        end
      end

      return nil
    end
  end
end
