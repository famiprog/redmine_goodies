module RedmineGoodiesQuickEditHelper
  CF_ID_PATTERN = /\Acf_(\d+)\z/

  # Parses a comma/semicolon-separated field list (same format as quick edit and reorder settings).
  # Splits only on comma/semicolon so field names with spaces (e.g. "🔥Pr dev") are preserved.
  def self.parse_fields_list(raw)
    return [] if raw.blank?
    raw.to_s.split(/\s*[,;]\s*/).map(&:strip).reject(&:blank?)
  end

  # Returns an array of { "cf_id" => "cf_N", "caption" => "..." } for any CFs (any type) matching
  # the given field list. Used by the reorder "Force enablement" setting: these fields bypass both
  # the float-type check and the sort-indicator check (for third-party plugin tables that omit those signals).
  def self.reorder_force_field_ids(raw_string)
    entries = parse_fields_list(raw_string)
    return [] if entries.empty?

    list = get_list_of_fields(entries)
    list.map do |c|
      if c.is_a?(QueryCustomFieldColumn)
        { 'cf_id' => "cf_#{c.custom_field.id}", 'caption' => c.caption.to_s }
      else
        { 'cf_id' => '', 'caption' => c.caption.to_s }
      end
    end
  end

  # Returns an array of { "cf_id" => "cf_N", "caption" => "..." } for float CFs that match the given field list.
  # Reuses get_list_of_fields for matching (DRY with quick edit). Used by reorder feature.
  def self.reorder_specified_float_cfs(raw_string)
    entries = parse_fields_list(raw_string)
    return [] if entries.empty?

    list = get_list_of_fields(entries)
    list.select { |c| c.is_a?(QueryCustomFieldColumn) && c.custom_field.field_format == 'float' }
       .map { |c| { 'cf_id' => "cf_#{c.custom_field.id}", 'caption' => c.caption.to_s } }
  end

  def self.get_list_of_fields(fields_to_copy)
    list_of_fields = nil
    I18n.with_locale(:en) do
      list_of_fields = IssueQuery.new.available_columns.select do |column|
        fields_to_copy.include?(column.caption) ||
          (column.is_a?(QueryCustomFieldColumn) &&
           fields_to_copy.any? { |f| f =~ CF_ID_PATTERN && $1.to_i == column.custom_field.id })
      end
    end
    list_of_fields
  end

  # Returns the human-readable display name for a field entry.
  # For "cf_N" entries, resolves to the custom field's caption; otherwise returns the entry as-is.
  def self.get_display_name(field_entry)
    return field_entry unless field_entry =~ CF_ID_PATTERN

    cf_id = $1.to_i
    col = nil
    I18n.with_locale(:en) do
      col = IssueQuery.new.available_columns.find do |c|
        c.is_a?(QueryCustomFieldColumn) && c.custom_field.id == cf_id
      end
    end
    col ? col.caption : field_entry
  end

  def self.get_issue_field_value(issue, field)
    return nil if issue.nil? || field.nil?

    if field.is_a?(QueryCustomFieldColumn)
      issue.custom_field_value(field.custom_field[:id])
    elsif issue.has_attribute?(field.name)
      issue[field.name]
    else
      issue.public_send(field.name)
    end
  end

  # Returns true if the given field can be edited by the user on the given issues.
  # Checks (in order):
  #   1. edit_issues permission on every project involved
  #   2. For custom fields: the global editable flag and role-based CF visibility
  #   3. Workflow field permissions (read-only rules set per tracker/status/role)
  # read_only_cache: optional flat hash that the caller can share across multiple calls
  # to avoid recomputing read_only_attribute_names for issues with the same
  # (project, tracker, status) combination.
  # Key format: "project_id_tracker_id_status_id"  (single-level, no nesting).
  def self.field_editable_by?(field_info, issues, user, read_only_cache: nil)
    return false if field_info.nil? || issues.blank?

    projects = issues.map(&:project).uniq
    return false unless projects.all? { |p| user.allowed_to?(:edit_issues, p) }

    if field_info.is_a?(QueryCustomFieldColumn)
      cf = field_info.custom_field
      return false unless cf.editable?
      return false if cf.roles.present? && projects.any? { |p| (user.roles_for_project(p) & cf.roles).empty? }
      # Redmine's read_only_attribute_names returns custom fields as their plain numeric id string (e.g. "5", not "cf_5")
      attr_name = cf.id.to_s
    else
      attr_name = field_info.name.to_s
    end

    # Workflow field permissions: the field must not be read-only on any of the issues.
    # read_only_attribute_names(user) queries WorkflowPermission by (tracker, status, roles);
    # the result is identical for all issues that share the same project+tracker+status,
    # so we memoize it in the caller-supplied cache when one is provided.
    issues.none? do |issue|
      read_only =
        if read_only_cache
          cache_key = "#{issue.project_id}_#{issue.tracker_id}_#{issue.status_id}"
          read_only_cache[cache_key] ||= issue.read_only_attribute_names(user)
        else
          issue.read_only_attribute_names(user)
        end
      read_only.include?(attr_name)
    end
  end
end

