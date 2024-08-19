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
end