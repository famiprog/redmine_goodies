module RedmineGoodiesQuickEditHelper
  def self.get_list_of_fields(fields_to_copy)
    list_of_fields = nil
    I18n.with_locale(:en) do
      list_of_fields = IssueQuery.new.available_columns.select { |column| fields_to_copy.include? column.caption }
    end
    list_of_fields
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
end

