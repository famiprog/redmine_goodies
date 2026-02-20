class QualityOfLifeTad {
    /**
     * Sometimes, with the context menu open, when opening a sub-menu: the "child" sub menu is too high and exits the screen. Hence we have some JS code that works around this issue by repositioning the popup.
     * 
     * Before:
     * 
     * @img image1.png
     * 
     * After:
     * 
     * @img image2.png
     * 
     * Settings:
     * 
     * @img settings.png
     */
    @Scenario()
    feature_repositionSubmenuOfContextMenu() {}

    /**
     * When there are several actions in the sub-menu, at some point the max-height is reached and a scroll bar appears. The Redmine default is about 300px, which means about 15 lines.
     * 
     * @img image1.png
     * 
     * Although general, this was meant for `Quick edit field`. This is something that needs to be "quick". And if there are quite a few fields, some on 2 lines => a scroll bar may appear. Which would make the "quick" ... less quick 🙂.
     * 
     * Settings:
     * 
     * @img image2.png
     * 
     */
    @Scenario()
    feature_overrideMaxHeightOfSubmenu() {}
}