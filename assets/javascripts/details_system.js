if (typeof jsToolBar !== 'undefined') {
    jsToolBar.prototype.elements.space7= {
        type: 'space',
    };

    jsToolBar.prototype.elements.details_macro = {
        type: 'button',
        title: 'Details macro',
        fn: {
            wiki: function () {
                this.encloseLineSelection('<details>\n\n', '\n\n</details>');
            }
        }
    };

    jsToolBar.prototype.elements.details_with_summary_macro = {
        type: 'button',
        title: 'Details with summary macro',
        fn: {
            wiki: function () {
                this.encloseLineSelection('<details><summary>Click to expand</summary>\n\n', '\n\n</details>');
            }
        }
    };
}