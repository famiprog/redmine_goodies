(function ($) {
  var $popup   = null;
  var $backdrop = null;
  var $links   = null;
  var loaded   = false;
  var loading  = false;

  function injectCss() {
    if (document.getElementById('rg-my-quick-menu-css')) { return; }
    var css =
      '#rg-my-quick-menu-backdrop {'                                        +
      '  display: none;'                                                    +
      '  position: fixed;'                                                  +
      '  top: 0; left: 0; right: 0; bottom: 0;'                           +
      '  z-index: 9998;'                                                    +
      '}'                                                                    +
      '#rg-my-quick-menu-popup {'                                           +
      '  display: none;'                                                    +
      '  position: fixed;'                                                  +
      '  z-index: 9999;'                                                    +
      '  background: #fff;'                                                 +
      '  border: 1px solid #ccc;'                                           +
      '  border-radius: 4px;'                                               +
      '  box-shadow: 0 4px 16px rgba(0,0,0,0.18);'                         +
      '  padding: 12px 16px;'                                               +
      '  min-width: 220px;'                                                 +
      '  max-width: 420px;'                                                 +
      '  max-height: 80vh;'                                                 +
      '  overflow-y: auto;'                                                 +
      '}'                                                                    +
      '#rg-my-quick-menu-popup .nodata {'                                   +
      '  color: #888;'                                                      +
      '  font-style: italic;'                                               +
      '}';
    var style = document.createElement('style');
    style.id = 'rg-my-quick-menu-css';
    style.appendChild(document.createTextNode(css));
    document.getElementsByTagName('head')[0].appendChild(style);
  }

  function positionPopup($anchor) {
    var rect   = $anchor[0].getBoundingClientRect();
    var popupW = $popup.outerWidth(true)  || 280;
    var popupH = $popup.outerHeight(true) || 200;
    var vw     = window.innerWidth;
    var vh     = window.innerHeight;

    // Horizontal: align to anchor left, clamp so popup stays inside viewport
    var left = Math.max(8, Math.min(rect.left, vw - popupW - 8));

    // Vertical: prefer below the anchor; flip above if there isn't enough room
    var top;
    if (rect.bottom + 4 + popupH < vh) {
      top = rect.bottom + 4;
    } else {
      top = rect.top - 4 - popupH;
    }
    top = Math.max(8, top);

    $popup.css({ top: top, left: left });
  }

  function showPopup($anchor) {
    $backdrop.show();
    $popup.show();
    positionPopup($anchor);

    if (!loaded && !loading) {
      loading = true;
      $popup.html('<p>' + window.RedmineGoodiesMyQuickMenu.i18n.loading + '</p>');
      $.ajax({
        url: window.RedmineGoodiesMyQuickMenu.url,
        success: function (html) {
          loaded = true;
          loading = false;
          $popup.html(html);
          positionPopup($anchor);
        },
        error: function () {
          loading = false;
          $popup.html('<p class="nodata">' + window.RedmineGoodiesMyQuickMenu.i18n.error + '</p>');
        }
      });
    }
  }

  function hidePopup() {
    $backdrop.hide();
    $popup.hide();
  }

  function togglePopup($anchor) {
    if ($popup.is(':visible')) {
      hidePopup();
    } else {
      showPopup($anchor);
    }
  }

  function init() {
    if (!window.RedmineGoodiesMyQuickMenu) { return; }

    injectCss();

    $backdrop = $('<div id="rg-my-quick-menu-backdrop"></div>').appendTo('body');
    $popup    = $('<div id="rg-my-quick-menu-popup"></div>').appendTo('body');

    // Match all menu links pointing to the quick menu route (desktop + mobile)
    $links = $('a[href$="/redmine_goodies_my_quick_menu"]');
    if (!$links.length) { return; }

    $links.on('click', function (e) {
      e.preventDefault();
      togglePopup($(this));
    });

    // Backdrop owns the "tap/click outside" interaction on both desktop and mobile
    $backdrop.on('click touchend', hidePopup);

    // Reposition on window resize if visible
    $(window).on('resize', function () {
      if ($popup && $popup.is(':visible') && $links.length) {
        positionPopup($links.first());
      }
    });
  }

  $(document).ready(init);
})(jQuery);
