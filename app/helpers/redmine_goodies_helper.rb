module RedmineGoodiesHelper

    JSON_FIELDS = { FIELD: "field", VALUE: "value", TRIGGER: "trigger", ACTIONS: "actions", A_ACTION: "action", A_FIELD: "field", A_NEW_VALUE: "newValue" }
    TRIGGERS = { WHEN_CHANGE_FROM: "when-changed-from", WHEN_CHANGE_TO: "when-changed-to" }
    ACTION_TYPES = { RESET_FIELD: "reset-field", SET_VALUE: "set-value" }

    def apply_actions(field_actions)
        field = field_actions[JSON_FIELDS[:FIELD]]
        value = field_actions[JSON_FIELDS[:VALUE]]
        trigger = field_actions[JSON_FIELDS[:TRIGGER]]
        actions = field_actions[JSON_FIELDS[:ACTIONS]]

        issue = Issue.find_by(id: params[:id])
        if issue.nil?
            Rails.logger.error("Issue with ID #{params[:id]} not found.")
            return
        end

        issue_field = get_issue_field(field, issue)
        issue_field_value = issue_field.respond_to?(:name) ? issue_field.name : issue_field
    
        if trigger == TRIGGERS[:WHEN_CHANGE_FROM] && issue_field_value != value
            perform_actions(actions, issue)
            return
        end

        if trigger == TRIGGERS[:WHEN_CHANGE_TO] && issue_field_value == value
            perform_actions(actions, issue)
            return
        end
    end

    def perform_actions(actions, issue)
        actions.each do |action|
            if action[JSON_FIELDS[:A_ACTION]] == ACTION_TYPES[:RESET_FIELD]
                modify_custom_field_value(action[JSON_FIELDS[:A_FIELD]], issue, nil)
            elsif action[JSON_FIELDS[:A_ACTION]] == ACTION_TYPES[:SET_VALUE]
                modify_custom_field_value(action[JSON_FIELDS[:A_FIELD]], issue, action[JSON_FIELDS[:A_NEW_VALUE]])
            end
        end
    end

    def modify_custom_field_value(cf_name, issue, value)
        cf_issue = issue.custom_field_values.find { |cfv| cfv.custom_field.name == cf_name }
        
        if cf_issue.nil?
            Rails.logger.error("Custom field '#{cf_name}' not found for issue ##{issue.id}")
            return
        end

        cf_definition = CustomField.find_by(name: cf_name)

        if value.nil?
            cf_issue.value = cf_definition.default_value.presence || nil # to check if it's working with all types of custom fields
        else
            cf_issue.value = value
        end

        if !issue.save
            Rails.logger.error("Failed to save modification for custom field '#{cf_name}' on issue ##{issue.id}")
        end
        Rails.logger.info("Custom field '#{cf_name}' on issue ##{issue.id} has been modified")
    end

    def get_issue_field(field, issue)
        field_map = { I18n.t(:field_status) => "status", I18n.t(:field_assigned_to) => "assigned_to", I18n.t(:field_author) => "author", 
            I18n.t(:field_priority) => "priority", I18n.t(:field_tracker) => "tracker", I18n.t(:field_category) => "category",
            I18n.t(:field_subject) => "subject", I18n.t(:field_description) => "description", I18n.t(:field_start_date) => "start_date",
            I18n.t(:field_due_date) => "due_date", I18n.t(:field_estimated_hours) => "estimated_hours", I18n.t(:field_done_ratio) => "done_ratio",
            I18n.t(:field_created_on) => "created_on", I18n.t(:field_updated_on) => "updated_on"
        }
        if field_map.key?(field)
            return issue.send(field_map[field])
        end
    end

end