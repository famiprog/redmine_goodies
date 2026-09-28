(function($) {
  // Shared minimal modal helper (DRY with quick edit + reorder),
  // including the compact layout tweaks used by the quick edit modal.
  window.RedmineGoodiesModal = window.RedmineGoodiesModal || {
    ensureCompactLayout: function() {
      if (document.getElementById('redmine-goodies-modal-css')) { return; }
      var css = ''
        + '#ajax-modal { padding-bottom: 0 !important; min-height: 0 !important; }'
        + '#ajax-modal form { margin-bottom: 0 !important; }'
        + '#ajax-modal .box { margin-bottom: 0.6em !important; }';
      var style = document.createElement('style');
      style.id = 'redmine-goodies-modal-css';
      style.type = 'text/css';
      style.appendChild(document.createTextNode(css));
      document.getElementsByTagName('head')[0].appendChild(style);
    },
    show: function(content, widthPx) {
      this.ensureCompactLayout();
      var $container = $('#ajax-modal');
      $container.empty();
      if (content && content.jquery) {
        $container.append(content);
      } else if (typeof content === 'string') {
        $container.html(content);
      }
      showModal('ajax-modal', widthPx || '505px');
    }
  };
})(jQuery);


