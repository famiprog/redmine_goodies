class RedmineGoodiesReorderController < ApplicationController

  before_action :find_issues, :only => [:recalculate_field, :activate_reorder]
  before_action :find_field_info, :only => [:recalculate_field]
  before_action :check_field_permission, :only => [:recalculate_field]

  # Assign sequential float values (1, 2, 3 … N) to the given issues in the submitted order.
  # Expects: ids (comma-separated, in desired order), field_name (float CF).
  def recalculate_field
    unless @field_info.is_a?(QueryCustomFieldColumn) && @field_info.custom_field.field_format == 'float'
      render plain: 'Field must be a float custom field', status: :unprocessable_entity
      return
    end

    # Restore the visual order supplied by the client (Issue.where does not preserve it).
    @issues = @issues.sort_by { |i| @ordered_param_ids.index(i.id.to_s) || 9999 }

    Issue.transaction do
      @issues.each_with_index do |issue, index|
        value = (index + 1).to_s
        issue.init_journal(User.current)
        issue.custom_field_values = { @field_info.custom_field[:id] => value }
        issue.save!
      end
    end

    flash[:notice] = l(:notice_successful_update) + '<div class="hidden" id="js-position">' + params['js_position'].to_s.html_safe + '</div>'
  rescue Exception => e
    logger.error e
    flash[:error] = l(:quick_edit_fail_update, error: "#{e}")
  ensure
    redirect_to_referer_or { render plain: 'Recalculate field saved.' }
  end

  # Returns the reorder config (cfEditability, specifiedFields, forceFields) for the given issues.
  # Called on-demand when the user clicks "Reorder issues" in the context menu.
  def activate_reorder
    editable = {}
    rw_cache = {}
    I18n.with_locale(:en) do
      IssueQuery.new.available_columns.each do |col|
        next unless col.is_a?(QueryCustomFieldColumn) && col.custom_field.field_format == 'float'
        key = "cf_#{col.custom_field.id}"
        editable[key] = RedmineGoodiesQuickEditHelper.field_editable_by?(col, @issues, User.current, read_only_cache: rw_cache)
      end
    end

    settings = Setting.plugin_redmine_goodies
    render json: {
      cfEditability:  editable,
      specifiedFields: RedmineGoodiesQuickEditHelper.reorder_specified_float_cfs(settings[:reorder_specified_fields]),
      forceFields:    RedmineGoodiesQuickEditHelper.reorder_force_field_ids(settings[:reorder_force_fields])
    }
  end

  private

  def find_issues
    ids = params[:ids] || params[:id]
    if ids.is_a?(String)
      ids = ids.split(',').map(&:strip)
    end
    @ordered_param_ids = Array(ids).map(&:to_s)
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
end

