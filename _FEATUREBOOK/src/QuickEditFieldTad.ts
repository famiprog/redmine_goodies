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
     * 
     * In the plugin configuration screen:
     * 
     * @img config.png
     */
    @Scenario()
    _quickInstructions() { }
}