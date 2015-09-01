module MailReceiver
  class Receiver
    include BodyParser

    def initialize(message, opts = {})
      @message = message
      @logger = opts[:logger]
    end

    def mail
      @message
    end

    def project_slug
      hash_data[:p]
    end

    def issue_id
      hash_data[:id]
    end

    def target_id
      hash_data[:n]
    end

    def merge_request?
      @merge_request ||= hash_data[:t].downcase == 'm'
    end

    def body
      return @body if defined?(@body)
      @body = self.extract
      @body
    end

    def to
      @to ||= @message.to.is_a?(Array) ? @message.to.first : @message.to
    end

    def from
      @from ||= @message.from.is_a?(Array) ? @message.from.first : @message.from
    end

    # foo@gmail.com => foo
    def prefix
      @prefix ||= to.split('@').first
    end

    # foo+p=chair/chair&id=123 => { p: chair/chair, id: 123 }
    def hash_data
      return @hash_data if defined?(@hash_data)
      return {} if not prefix.include?('+')
      @hash_data = Encoder.decode(prefix.split('+').last)
      return @hash_data
    end

    def inspect
      { project_slug: project_slug, issue_id: issue_id, target_id: target_id, merge_request: merge_request?, to: to, body: body}
    end

    def project
      @project ||= Project.find_with_namespace(project_slug)
    rescue => e
      logger.warn "Project: #{project_slug} record not found."
      nil
    end

    def process!
      if current_user.blank?
        logger.warn "Reply user: #{from} not found user in GitLab."
        return
      end

      if project.blank?
        logger.warn "Project #{project_slug} is not found."
        return
      end

      note_params = merge_request? ? process_mr! : process_issue!
      return if note_params.blank?

      note_params[:project_id] = project.id
      note_params[:target_id] = target_id
      note_params[:note] = body

      @note = Notes::CreateService.new(project, current_user, note_params).execute
      logger.info "Note #{@note.id} created."
    end

    def process_mr!
      @mr = project.merge_requests.find_by(iid: self.issue_id)
      if @mr.blank?
        logger.warn "MergeRequest #{self.issue_id} not found."
        return nil
      end

      logger.info "Found MergeRequest: #{@mr.id}"
      { noteable_type: 'MergeRequest', noteable_id: @mr.id }
    end

    def process_issue!
      @issue = project.issues.find_by(iid: self.issue_id)
      if @issue.blank?
        logger.warn "Issue #{self.issue_id} not found."
        return nil
      end

      logger.info "Found issue: #{@issue.id}"
      { noteable_type: 'Issue', noteable_id: @issue.id }
    end

    def current_user
      @current_user ||= User.find_by_any_email(from)
    end

    def logger
      @logger ||= Logger.new($stdout)
    end
  end
end
