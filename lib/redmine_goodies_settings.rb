class RedmineGoodiesSettings

    public

    def self.get_setting(name)
        value = Setting.plugin_redmine_goodies[name]
        # Return default value if setting is nil (e.g. new setting after upgrade)
        if value.nil?
            defaults = {
                :remove_lazy_loading => '1',
                :collapsible_images => '0',
                :reposition_context_submenu => '1',
                :context_submenu_max_height => '',
                :fields_to_quick_edit => '',
                :add_parent_to_quick_edit => '0'
            }
            return defaults[name]
        end
        value
    end

    def self.remove_lazy_loading?
        return get_setting(:remove_lazy_loading) == '1'
    end

    def self.collapsible_images?
        return get_setting(:collapsible_images) == '1'
    end

    def self.reposition_context_submenu?
        return get_setting(:reposition_context_submenu) != '0'
    end

    def self.context_submenu_max_height
        get_setting(:context_submenu_max_height).to_s.strip
    end

    # Returns a safe CSS value for context submenu max-height, or nil if not set/invalid
    def self.context_submenu_max_height_css
        v = context_submenu_max_height
        return nil if v.blank?
        v = v.strip
        v = "#{v}px" if v =~ /\A\d+\z/
        v =~ /\A[\d.]+(px|%|em|rem)?\z/i ? v : nil
    end

    def self.fields_to_quick_edit
        get_setting(:fields_to_quick_edit)
    end

    def self.add_parent_to_quick_edit?
        get_setting(:add_parent_to_quick_edit) == '1'
    end

    def self.organize_custom_queries?
        (get_setting(:organize_custom_queries).presence || '1') == '1'
    end

    def self.enable_issue_reorder?
        (get_setting(:enable_issue_reorder).presence || '1') == '1'
    end

    def self.reorder_enable_for
        (get_setting(:reorder_enable_for) || 'any').to_s
    end

    # Returns an array of normalized field identifiers (downcased, stripped).
    # Accepts names or cf_N style ids, separated by commas/semicolons/newlines.
    def self.reorder_specified_fields
        raw = (get_setting(:reorder_specified_fields) || '').to_s
        raw
          .split(/[\s,;]+/)
          .map(&:strip)
          .reject(&:blank?)
          .map(&:downcase)
    end

    def self.reorder_force_fields
        (get_setting(:reorder_force_fields) || '').to_s
    end
end