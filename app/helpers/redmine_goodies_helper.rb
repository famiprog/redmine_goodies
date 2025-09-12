module RedmineGoodiesHelper

    JSON_FIELDS = { FIELD: "field", FROM_VALUE: "fromValue", TO_VALUE: "toValue", ACTIONS: "actions", A_ACTION: "action", A_FIELD: "field", A_NEW_VALUE: "newValue" }
    TRIGGERS = { WHEN_CHANGE_FROM: "when-changed-from", WHEN_CHANGE_TO: "when-changed-to" }
    ACTION_TYPES = { RESET_FIELD: "reset-field", SET_VALUE: "set-value", COPY_TO_FIELD: "copy-to-field" }

    def apply_actions(issue, field_actions)
        field = field_actions[JSON_FIELDS[:FIELD]]
        from_value = field_actions[JSON_FIELDS[:FROM_VALUE]]
        to_value = field_actions[JSON_FIELDS[:TO_VALUE]]
        actions = field_actions[JSON_FIELDS[:ACTIONS]]
        issue_field_value = get_field_value_by_label(field, issue)
        attribute_previous_value = get_field_previous_value(field, issue)  # if blank, the issue field didn't change
        from_value = nil if from_value == "nil"
        to_value = nil if to_value == "nil"

        # E.g. fromValue = new; toValue = "" ||  fromValue = ""; toValue = "assigned" || fromValue = "new"; toValue = "assigned"
        if (to_value.blank? && issue_field_value != from_value && (!attribute_previous_value.blank? && attribute_previous_value == from_value || field == "Closed")) ||
                (from_value.blank? && issue_field_value == to_value && !attribute_previous_value.blank? && attribute_previous_value != to_value) ||
                (issue_field_value == to_value && !attribute_previous_value.blank? && attribute_previous_value == from_value)
            perform_actions(actions, issue, field, issue_field_value)
            # return
        end
    end

    def perform_actions(actions, issue, field, issue_field_value)
        changes_logs = []
        issue.custom_field_values if issue.custom_field_values.empty?
        actions.each do |action|
            if action[JSON_FIELDS[:A_ACTION]] == ACTION_TYPES[:RESET_FIELD]
                was_action_applied = modify_custom_field_value(action[JSON_FIELDS[:A_FIELD]], issue, nil)
                was_action_applied && changes_logs << l(:actions_to_trigger_when_fields_are_changed_status_success, action_performed: ACTION_TYPES[:RESET_FIELD], field_name: action[JSON_FIELDS[:A_FIELD]])
            elsif action[JSON_FIELDS[:A_ACTION]] == ACTION_TYPES[:SET_VALUE]
                was_action_applied = modify_custom_field_value(action[JSON_FIELDS[:A_FIELD]], issue, action[JSON_FIELDS[:A_NEW_VALUE]])
                was_action_applied && changes_logs << l(:actions_to_trigger_when_fields_are_changed_status_success, action_performed: ACTION_TYPES[:SET_VALUE], field_name: action[JSON_FIELDS[:A_FIELD]])
            elsif action[JSON_FIELDS[:A_ACTION]] == ACTION_TYPES[:COPY_TO_FIELD]
                was_action_applied = modify_custom_field_value(action[JSON_FIELDS[:A_FIELD]], issue, issue_field_value)
                was_action_applied && changes_logs << l(:actions_to_trigger_when_fields_are_changed_status_success, action_performed: ACTION_TYPES[:COPY_TO_FIELD], field_name: action[JSON_FIELDS[:A_FIELD]])
            end
        end
        display_fields_changes_status(field, changes_logs)
    end

    def modify_custom_field_value(cf_name, issue, value)
        column = nil
        I18n.with_locale(:en) do
            column = IssueQuery.new.available_columns.find { |col| col.caption == cf_name }
        end

        cf_issue = issue.custom_field_values.find { |cfv| cfv.custom_field.name == column.custom_field.name }
        if cf_issue.nil?
            flash[:warning] = l(:actions_to_trigger_when_fields_are_changed_status_warning, cf_name: cf_name, issue_id: issue.id)
            return false
        end

        if value.nil?
            cf_issue.value = cf_issue.custom_field.default_value.presence || nil
        else
            cf_issue.value = !value.is_a?(ActiveSupport::TimeWithZone) ? value : value.strftime("%m/%d/%Y")
        end
        return true
    end

    def get_field_value_by_label(label, issue)
        column = nil
        I18n.with_locale(:en) do
            column = IssueQuery.new.available_columns.find { |col| col.caption == label }
        end
        return nil unless column
        value = column.value(issue)
        return value.respond_to?(:name) ? value.name : value.to_s
    end

    def get_field_previous_value(attr_name, issue)
        last_journal = issue.journals.order(created_on: :desc).first
        return nil unless last_journal

        last_journal.details.each do |detail|
            # issue attributes, such as: Status, Assignee, Subject etc
            if Issue.human_attribute_name(detail.prop_key) == attr_name
                # checking if the `old_value` is an `id`(eg: 2) or directly the value (Redmine goodies new features)
                return detail.old_value.match?(/\A\d+\z/) ? get_field_value_by_id(attr_name, detail.old_value, issue.id) : detail.old_value
            end
            
            custom_field = CustomField.find_by(id: detail.prop_key.to_i)
            return detail.old_value if custom_field&.name == attr_name
        end
        return nil
    end

    def get_field_value_by_id(attribute_name, id, issue_id)
        column = nil
        I18n.with_locale(:en) do
            column = IssueQuery.new.available_columns.find { |col| col.caption == attribute_name }
        end
        return nil unless column
        model_class = case column.name.to_s
            when 'status'      then IssueStatus
            when 'assigned_to' then User
            when 'priority'    then IssuePriority
            when 'category'    then IssueCategory
            when 'project'     then Project
            when 'tracker'     then Tracker
        end
        return model_class&.find_by(id: id)&.name if model_class
        custom_field = IssueCustomField.find_by(name: attribute_name)
        if custom_field
            custom_value = CustomValue.find_by(custom_field_id: custom_field.id, customized_id: issue_id)
            return custom_value&.value
        end
        return nil
    end

    def display_fields_changes_status(field, list)
        html =  l(:actions_to_trigger_when_fields_are_changed_status, field_name: field)
        html += '<ul>'
        list.each do |info|
          html += '<li>' + info + '</li>'
        end
        html += '</ul>'
        flash[:notice] << html if flash[:notice].present?
    end
end