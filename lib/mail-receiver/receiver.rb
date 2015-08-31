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
      @project_slug ||= id_prefix.split(/!|#/).first
    end

    def issue_id
      @issue_id ||= id_prefix.split(/!|#/).last
    end

    def merge_request?
      @merge_request ||= id_prefix.match('!')
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

    def inspect
      { project_slug: project_slug, issue_id: issue_id, merge_request: merge_request?, to: to, body: body}
    end

    def project
      @project ||= Project.find_with_namespace(project_slug)
    rescue => e
      logger.warn "Project: #{project_slug} record not found."
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

    private

    def logger
      @logger ||= Logger.new($stdout)
    end

    # foo+chair/chair!123 => chair/chair!123
    def id_prefix
      return @id_prefix if defined?(@id_prefix)
      @id_prefix = prefix.split('+').last
      return @id_prefix
    end
  end
end
