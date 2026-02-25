class OrganizeCustomQueriesTad {

    /**
     * Custom queries (in the right-hand bar) are grouped in `My custom queries` and `Custom queries`.
     * 
     * This feature:
     * 
     * @img link.png
     * 
     * splits `Custom queries` into `Custom queries (this project)` and `Custom queries (all projects)`, using the same styling for the titles/"separators":
     * 
     * @img after-org.png
     * 
     * Each CQ (all projects) has a link to open that CQ in "all projects mode".
     * 
     * @img all-proj.png
     * 
     * After the last CQ, there is a `<hr />` and then the helper text.
     * 
     * @img helper.png
     */
    @Scenario()
    _quickInstructions() { }

}