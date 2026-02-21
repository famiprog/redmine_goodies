class RedmineGoodiesQuickEditController < ApplicationController

  before_action :find_issues, :only => [:edit_field, :update_field]
  before_action :find_field_info, :only => [:edit_field, :update_field]
  before_action :check_field_permission, :only => [:edit_field, :update_field]

  # prepare data for modal form
  def edit_field
    @issues ||= []
    @issue_ids = @issues.map(&:id)
    @field_name = params[:field_name]
    @field_display_name = RedmineGoodiesQuickEditHelper.get_display_name(@field_name)

    @field_value = get_issue_field_value(@issues.first, @field_info)

    # Optional generic params that any caller can pass to customise the modal:
    #   modal_extra_html     – HTML displayed above the input (sanitized by the view)
    #   modal_proposed_value – pre-fills the input instead of the current field value
    #   modal_cancel_reload  – if '1', Cancel reloads the page instead of just closing the modal
    @modal_extra_html = params[:modal_extra_html].presence
    @modal_cancel_reload = params[:modal_cancel_reload] == '1'
    @field_value = params[:modal_proposed_value] if params[:modal_proposed_value].present?

    if @field_info.name == :parent
      # we need to send only the id in case we want to edit the parent field
      @field_value = @field_value.id unless @field_value.nil?
    end
  end

  # execute on ok from modal form
  def update_field
    value = params[:edit_field_value]

    Issue.transaction do
      @issues.each do |issue|
        issue.init_journal(User.current)

        if @field_info.is_a?(QueryCustomFieldColumn)
          issue.custom_field_values
          issue.custom_field_values = { @field_info.custom_field[:id] => value }
        elsif @field_info.name == :parent
          # we need to set parent_issue_id and not parent
          # so that redmine properly updates the tree
          # also it knows to validate the info in case it is nil, not integer
          # or the same id as the current issue
          issue.parent_issue_id = value
        else
          if issue.has_attribute?(@field_info.name)
            issue[@field_info.name] = value
          else
            issue.public_send("#{@field_info.name}=", value)
          end
        end

        
        # TODO discussion in progress in PR for better solution
        # BEGIN
        # issue.save!

        # If Crispico prefix / copy-field logic is available, reuse it so that
        # subject prefixes and "on field1 modified => copy to field2" continue to work.
        if respond_to?(:get_subject_without_prefix) && respond_to?(:compute_prefix_from_parent_id)
          subject = get_subject_without_prefix(issue.subject)
          prefix = compute_prefix_from_parent_id(issue.parent_issue_id)
          issue.subject = prefix.length > 0 ? "#{prefix} #{subject}" : subject
        end

        default_context = nil
        if respond_to?(:before_save_issue)
          default_context = {
            controller: self,
            issue: issue,
            params: { id: issue.id, issue: issue },
            is_new: false
          }
          before_save_issue(default_context)
        end

        if issue.save! && respond_to?(:after_save_issue) && default_context
          after_save_issue(default_context)
        end
        # END
      end
    end

    flash[:notice] = l(:notice_successful_update) + '<div class="hidden" id="js-position">' + params['js_position'].to_s.html_safe + '</div>'
  rescue Exception => e
    logger.error e
    flash[:error] = l(:quick_edit_fail_update, error: "#{e}")
  ensure
    redirect_to_referer_or { render plain: 'Edit field saved.' }
  end

  private

  def find_issues
    ids = params[:ids] || params[:id]
    if ids.is_a?(String)
      ids = ids.split(',').map(&:strip)
    end
    @issues = Issue.where(id: ids)
  end

  def find_field_info
    fields = RedmineGoodiesQuickEditHelper.get_list_of_fields([params[:field_name]])
    @field_info = fields[0]
  end

  def check_field_permission
    unless RedmineGoodiesQuickEditHelper.field_editable_by?(@field_info, @issues, User.current)
      render_403
    end
  end

  def get_issue_field_value(issue, field)
    RedmineGoodiesQuickEditHelper.get_issue_field_value(issue, field)
  end
end

