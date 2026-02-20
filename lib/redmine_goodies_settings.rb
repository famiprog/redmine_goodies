class RedmineGoodiesSettings

    public

    def self.get_setting(name)
        return Setting.plugin_redmine_goodies[name]
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
end