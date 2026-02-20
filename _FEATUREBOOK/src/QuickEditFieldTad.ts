class QuickEditFieldTad {
    
    /**
     * Redmine offers quick field edit only for fields of type many-to-one (e.g. `Status`, `Tracker`, etc.). This
     * feature extends the quick edit flow to "normal" fields.
     * 
     * The context menu (right click) of an issue has this:
     * 
     * @img context-menu.png
     * 
     * And then:
     * 
     * @img popup.png
     */
    @Scenario()
    _quickInstructions() { }

    /**
     * In the plugin configuration screen:
     * 
     * @img image.png
     */
    @Scenario
    feature_settings() { }

    
    /**
     * In order to access the feature, the "edit issue" permission needs to be present.
     * And the field needs to be "read/write". E.g. if read only:
     * 
     * @img image.png
     */
    @Scenario
    feature_permissions() { }
}