module RedmineGoodiesHelper

    JSON_FIELDS = { FIELD: "field", FROM_VALUE: "fromValue", TO_VALUE: "toValue", ACTIONS: "actions", A_ACTION: "action", A_FIELD: "field", A_NEW_VALUE: "newValue" }
    TRIGGERS = { WHEN_CHANGE_FROM: "when-changed-from", WHEN_CHANGE_TO: "when-changed-to" }
    ACTION_TYPES = { RESET_FIELD: "reset-field", SET_VALUE: "set-value", COPY_TO_FIELD: "copy-to-field" }

    def apply_actions(issue, field_actions)
        field = field_actions[JSON_FIELDS[:FIELD]]
        from_value = field_actions[JSON_FIELDS[:FROM_VALUE]]
        to_value = field_actions[JSON_FIELDS[:TO_VALUE]]
        actions = field_actions[JSON_FIELDS[:ACTIONS]]
        issue_field_value = get_field_value(field, issue)
        attribute_previous_value = get_field_previous_value(field, issue)  # if blank, the issue field didn't change
        from_value = nil if from_value == "nil"
        to_value = nil if to_value == "nil"

        # E.g: fromValue = new; toValue = ""
        if to_value.blank? && issue_field_value != from_value && (!attribute_previous_value.blank? && attribute_previous_value == from_value || field == "Closed")
            perform_actions(actions, issue, field, issue_field_value)
            return
        end
        # E.g: fromValue = ""; toValue = "assigned"
        if from_value.blank? && issue_field_value == to_value && !attribute_previous_value.blank? && attribute_previous_value != to_value
            perform_actions(actions, issue, field, issue_field_value)
            return
        end
        # E.g: fromValue = "new"; toValue = "assigned"
        if issue_field_value == to_value && !attribute_previous_value.blank? && attribute_previous_value == from_value
            perform_actions(actions, issue, field, issue_field_value)
            return
        end
    end

    def perform_actions(actions, issue, field, issue_field_value)
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
        display_fields_changes_status(field, changes_logs)
    end

    def modify_custom_field_value(cf_name, issue, value)
        cf_issue = issue.custom_field_values.find { |cfv| cfv.custom_field.name == cf_name }
        
        if cf_issue.nil?
            flash[:warning] = l(:actions_to_trigger_when_fields_are_changed_status_warning, cf_name: cf_name, issue_id: issue.id)
            return false
        end

        if value.nil?
            cf_definition = CustomField.find_by(name: cf_name)
            cf_issue.value = cf_definition.default_value.presence || nil
        else
            cf_issue.value = !value.is_a?(ActiveSupport::TimeWithZone) ? value : value.strftime("%m/%d/%Y")
        end
        return true
    end

    def get_issue_field(label, issue)
        # issue attributes, such as: Status, Assignee, Subject etc
        issue_attributes = Issue.new.attributes.keys
        issue_attributes.each do |attribute|
          attribute = attribute.sub(/_id$/, '')  # eg: status_id -> status
          field_label = I18n.t("field_#{attribute}")
          return issue.send(attribute) if field_label == label
        end
        
        custom_field = IssueCustomField.find_by(name: label)
        if custom_field
          custom_value = CustomValue.find_by(custom_field_id: custom_field.id, customized_id: issue.id)
          return custom_value&.value
        end
        return nil
    end

    def get_field_value(field, issue)
        issue_field = get_issue_field(field, issue)
        issue_field_value = issue_field.respond_to?(:name) ? issue_field.name : issue_field
        return issue_field_value
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
        fields_values_by_id = {
            I18n.t(:field_status) => ->(id) { IssueStatus.find_by(id: id)&.name },
            I18n.t(:field_assigned_to) => ->(id) { User.find_by(id: id)&.name },
            I18n.t(:field_priority) => ->(id) { IssuePriority.find_by(id: id)&.name },
            I18n.t(:field_category) => ->(id) { IssueCategory.find_by(id: id)&.name },
            I18n.t(:field_project) => ->(id) { Project.find_by(id: id)&.name },
            I18n.t(:field_tracker) => ->(id) { Tracker.find_by(id: id)&.name }
        }
        get_field_value = fields_values_by_id[attribute_name]
        value = get_field_value ? get_field_value.call(id) : nil
        return value if !value.nil?

        custom_field = IssueCustomField.find_by(name: attribute_name)
        if custom_field
            custom_value = CustomValue.find_by(custom_field_id: custom_field.id, customized_id: issue_id)
            return custom_value&.value
        end
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