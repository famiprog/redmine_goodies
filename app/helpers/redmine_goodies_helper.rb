module RedmineGoodiesHelper

    JSON_FIELDS = { FIELD: "field", FROM_VALUE: "fromValue", TO_VALUE: "toValue", ACTIONS: "actions", A_ACTION: "action", A_FIELD: "field", A_NEW_VALUE: "newValue" }
    TRIGGERS = { WHEN_CHANGE_FROM: "when-changed-from", WHEN_CHANGE_TO: "when-changed-to" }
    ACTION_TYPES = { RESET_FIELD: "reset-field", SET_VALUE: "set-value", COPY_TO_FIELD: "copy-to-field" }

    def apply_actions(field_actions)
        field = field_actions[JSON_FIELDS[:FIELD]]
        from_value = field_actions[JSON_FIELDS[:FROM_VALUE]]
        to_value = field_actions[JSON_FIELDS[:TO_VALUE]]
        actions = field_actions[JSON_FIELDS[:ACTIONS]]

        issue = Issue.find_by(id: params[:id])
        if issue.nil?
            Rails.logger.error("Issue with ID #{params[:id]} not found.")
            return
        end

        issue_field_value = get_field_value(field, issue)
        attribute_previous_value = get_attribute_previous_value(field, issue)  # if blank, the issue field didn't change

        # E.g: fromValue = new; toValue = ""
        if to_value.blank? && issue_field_value != from_value && !attribute_previous_value.blank? && attribute_previous_value == from_value
            perform_actions(actions, issue, field)
            return
        end
        # E.g: fromValue = ""; toValue = "assigned"
        if from_value.blank? && issue_field_value == to_value && !attribute_previous_value.blank? && attribute_previous_value != to_value
            perform_actions(actions, issue, field)
            return
        end
        # E.g: fromValue = "new"; toValue = "assigned"
        if issue_field_value == to_value && !attribute_previous_value.blank? && attribute_previous_value == from_value
            perform_actions(actions, issue, field)
            return
        end
    end

    def perform_actions(actions, issue, field)
        issue_field_value = get_field_value(field, issue)
        changes_logs = []

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

        if !issue.save
            flash[:error] = l(:actions_to_trigger_when_fields_are_changed_status_error, issue_id: issue.id)
            return
        end
        display_fields_changes_status(field, changes_logs)
    end

    def modify_custom_field_value(cf_name, issue, value)
        cf_issue = issue.custom_field_values.find { |cfv| cfv.custom_field.name == cf_name }
        
        if cf_issue.nil?
            flash[:warning] = l(:actions_to_trigger_when_fields_are_changed_status_warning, cf_name: cf_name, issue_id: issue.id)
            return false
        end

        cf_definition = CustomField.find_by(name: cf_name)
        if value.nil?
            cf_issue.value = cf_definition.default_value.presence || nil
        else
            cf_issue.value = value
        end
        return true
    end

    def get_issue_field(field, issue)
        field_map = { I18n.t(:field_status) => "status", I18n.t(:field_assigned_to) => "assigned_to", I18n.t(:field_priority) => "priority", I18n.t(:field_category) => "category", I18n.t(:field_project) => "project", I18n.t(:field_tracker) => "tracker" }

        if field_map.key?(field)
            return issue.send(field_map[field])
        end
    end

    def get_field_value(field, issue)
        issue_field = get_issue_field(field, issue)
        issue_field_value = issue_field.respond_to?(:name) ? issue_field.name : issue_field
        return issue_field_value
    end

    def get_attribute_previous_value(attr_name, issue)
        last_journal = issue.journals.order(created_on: :desc).first
        if last_journal
            last_journal.details.each do |detail|
                if Issue.human_attribute_name(detail.prop_key) == attr_name
                    return get_attribute_name_by_id(attr_name, detail.old_value)
                end
            end
        end
        return nil
    end

    def get_attribute_name_by_id(attribute_name, id)
        search_methods = {
            I18n.t(:field_status) => ->(id) { IssueStatus.find_by(id: id)&.name },
            I18n.t(:field_assigned_to) => ->(id) { User.find_by(id: id)&.name },
            I18n.t(:field_priority) => ->(id) { IssuePriority.find_by(id: id)&.name },
            I18n.t(:field_category) => ->(id) { IssueCategory.find_by(id: id)&.name },
            I18n.t(:field_project) => ->(id) { Project.find_by(id: id)&.name },
            I18n.t(:field_tracker) => ->(id) { Tracker.find_by(id: id)&.name }
        }
      
        search_method = search_methods[attribute_name]
        return search_method ? search_method.call(id) : nil
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