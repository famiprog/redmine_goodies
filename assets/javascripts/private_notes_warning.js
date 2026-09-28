(function ($) {
  var MARK = 'rgPrivateNotesWarning';
  var SELECTOR = 'input[type="checkbox"][name="issue[private_notes]"], input[type="checkbox"][name="journal[private_notes]"]';

  function sync($checkbox) {
    var $warning = $checkbox.data('rgWarningEl');
    if (!$warning || !$warning.length) { return; }
    $warning.toggleClass('is-visible', $checkbox.prop('checked'));
  }

  function ensureWarning($checkbox) {
    if ($checkbox.data(MARK)) {
      sync($checkbox);
      return;
    }
    var text = window.RedmineGoodiesPrivateNotesWarning;
    if (!text) { return; }

    var $warning = $('<div class="rg-private-notes-warning" role="status"></div>').text(text);
    var id = $checkbox.attr('id');
    var $forLabel = id ? $('label[for="' + id + '"]') : $();
    var $parentLabel = $checkbox.parent('label');

    if ($forLabel.length) {
      $forLabel.last().after($warning);
    } else if ($parentLabel.length) {
      $parentLabel.after($warning);
    } else {
      $checkbox.after($warning);
    }
    $checkbox.data(MARK, true);
    $checkbox.data('rgWarningEl', $warning);
    sync($checkbox);
  }

  function scan(root) {
    var $root = root ? $(root) : $(document);
    var $boxes = $root.find(SELECTOR);
    if (root && $root.is(SELECTOR)) { $boxes = $boxes.add($root); }
    $boxes.each(function () { ensureWarning($(this)); });
  }

  $(function () {
    scan();
    if (window.MutationObserver && document.body) {
      var observer = new MutationObserver(function (mutations) {
        for (var i = 0; i < mutations.length; i++) {
          var nodes = mutations[i].addedNodes;
          for (var j = 0; j < nodes.length; j++) {
            if (nodes[j].nodeType === 1) { scan(nodes[j]); }
          }
        }
      });
      observer.observe(document.body, { childList: true, subtree: true });
    }
  });

  // Journal edit is loaded by rails-ujs (not jQuery.ajax), which inserts the form in the response script.
  document.addEventListener('ajax:complete', function () { setTimeout(scan, 0); });
  $(document).on('change', SELECTOR, function () { ensureWarning($(this)); });
})(jQuery);
