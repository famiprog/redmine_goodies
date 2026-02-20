module RedmineGoodiesQuickEditHelper
  CF_ID_PATTERN = /\Acf_(\d+)\z/

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
    if field.is_a?(QueryCustomFieldColumn)
      issue.custom_field_value(field.custom_field[:id])
    elsif issue.has_attribute?(field.name)
      issue[field.name]
    else
      issue.public_send(field.name)
    end
  end
end

