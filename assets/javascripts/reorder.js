// Find tables that have a sorted float custom-field column (cf_XX float + icon-sorted-*)
// and add a drag handle in each body cell for that column.
// On drop: open the existing Quick Edit modal with neighbor context and suggested value.

if (typeof jQuery !== 'undefined') {
    jQuery(document).ready(function() {
        var $ = jQuery;

        // Returns the numeric issue id from a row's DOM id attribute (e.g. "issue-1234" -> "1234")
        function getIssueIdFromRow($row) {
            var m = ($row.attr('id') || '').match(/(\d+)/);
            return m ? m[1] : '';
        }

        // Returns trimmed text of the nth cell in a row
        function getCellText($row, colIndex) {
            return $.trim($row.children('th,td').eq(colIndex).text());
        }

        // Open the Quick Edit modal via AJAX (JS format so Rails uses edit_field.js.erb).
        // options (all optional):
        //   extraHtml      – HTML string shown above the input
        //   proposedValue  – pre-fills the input
        //   cancelReload   – if true, Cancel reloads the page
        function openQuickEdit(issueId, fieldName, options) {
            var data = {
                ids: issueId,
                field_name: fieldName,
                js_position: $(window).scrollTop()
            };
            if (options) {
                if (options.extraHtml)                    { data.modal_extra_html     = options.extraHtml; }
                if (options.proposedValue !== undefined)  { data.modal_proposed_value = options.proposedValue; }
                if (options.cancelReload)                 { data.modal_cancel_reload  = '1'; }
            }
            $.ajax({
                url: '/redmine_goodies_edit_field.js',
                type: 'GET',
                data: data,
                dataType: 'script'
            });
        }

        $('table').each(function() {
            var $table = $(this);
            var $headerRow = $table.find('thead tr').first();
            if ($headerRow.length === 0) { return; }

            var targetColumnIndexes = [];

            $headerRow.find('th').each(function(colIndex) {
                var $th = $(this);
                var classAttr = $th.attr('class') || '';
                // Must have cf_XX and float in class list
                if (!/cf_\d+/.test(classAttr) || classAttr.indexOf('float') === -1) { return; }
                // Must contain a sorted link
                if ($th.find('a[class*="icon-sorted-"]').length === 0) { return; }
                targetColumnIndexes.push(colIndex);
            });

            if (targetColumnIndexes.length === 0) { return; }

            // Add drag handle into the matching cell of every body row
            $table.find('tbody tr').each(function() {
                var $row = $(this);
                var $cells = $row.children('th,td');

                targetColumnIndexes.forEach(function(colIndex) {
                    var $cell = $cells.eq(colIndex);
                    if ($cell.length === 0 || $cell.find('.sort-handle').length > 0) { return; }

                    var $handle = $('<span>', {
                        'class': 'icon-only icon-sort-handle sort-handle',
                        'title': 'Drag to reorder'
                    });
                    // Empty span: the green icon comes from the icon-sort-handle CSS class.
                    // No text content inside — that was what caused clipping.
                    $cell.prepend($handle);
                });
            });

            // Enable drag-and-drop on the tbody
            var $tbody = $table.find('tbody');
            if ($tbody.length === 0 || !$.fn.positionedItems) { return; }

            $tbody.positionedItems({
                update: function(event, ui) {
                    var $row = ui.item;

                    // Determine which CF column's handle was dragged
                    var $handleCell = $row.find('.sort-handle').first().closest('td,th');
                    var valueCol = $row.children('th,td').index($handleCell);
                    if (valueCol < 0) { return; }

                    // Field name from header link text
                    var fieldName = $.trim($headerRow.find('th').eq(valueCol).find('a').first().text());

                    // Current issue id from row DOM id (e.g. "issue-1234")
                    var curId = getIssueIdFromRow($row);
                    if (!curId) { return; }

                    // Neighbors — restrict to actual issue rows to skip group headers etc.
                    var $prev = $row.prevAll('tr[id^="issue-"]').first();
                    var $next = $row.nextAll('tr[id^="issue-"]').first();
                    var hasPrev = $prev.length > 0;
                    var hasNext = $next.length > 0;

                    // Parse float values from the CF column, tolerating formatting noise
                    function parseVal($r) {
                        return parseFloat(getCellText($r, valueCol).replace(/[^\d,.\-]/g, '').replace(',', '.'));
                    }
                    var prevVal = hasPrev ? parseVal($prev) : NaN;
                    var nextVal = hasNext ? parseVal($next) : NaN;
                    var prevOk  = hasPrev && !isNaN(prevVal);
                    var nextOk  = hasNext && !isNaN(nextVal);

                    // Build an issue link from what's available in the row DOM
                    function issueLinkHtml($r) {
                        var id      = getIssueIdFromRow($r);
                        var tracker = $.trim($r.find('td.tracker').first().text());
                        var $a      = $r.find('td.subject a').first();
                        var href    = $a.attr('href') || ('/issues/' + id);
                        var label   = (tracker ? tracker + ' #' + id : '#' + id);
                        return '<a href=\"' + href + '\">' + label + '</a>';
                    }

                    function issueSubjectHtml($r) {
                        var $a      = $r.find('td.subject a').first();
                        var subject = $.trim($a.text()) || getCellText($r, 0);
                        return $('<span>').text(subject).html();
                    }

                    var safeField = $('<span>').text(fieldName).html();

                    // Determine suggested value based on available neighbors
                    var suggested;
                    if (!hasPrev && nextOk) {
                        suggested = Math.floor(nextVal - 1);   // dropped at the top
                    } else if (!hasNext && prevOk) {
                        suggested = Math.ceil(prevVal + 1);    // dropped at the bottom
                    } else if (prevOk && nextOk) {
                        suggested = (prevVal + nextVal) / 2.0; // dropped in the middle
                    } else {
                        // A neighbor exists but its CF value is not populated
                        var fallbackHtml =
                            '<div class="warning" style="text-align:left;">' +
                            'The neighbors don\'t seem to have the <code>' + safeField + '</code> ' +
                            'field populated. Hence, a value cannot be proposed. Please edit it manually.' +
                            '</div>';
                        openQuickEdit(curId, fieldName, { extraHtml: fallbackHtml, cancelReload: true });
                        return;
                    }

                    // Build context HTML showing where the issue was dropped
                    var items = '<p>You dropped ' + issueLinkHtml($row) + '</p>';
                    items += '<p>' + issueSubjectHtml($row) + '</p><hr />';
                    if (prevOk) {
                        items += '<p>⬇️After (<code>' + safeField + '</code> = ' + prevVal + ') ' + issueLinkHtml($prev) + '</p>';
                        items += '<p>' + issueSubjectHtml($prev) + '</p><hr />';
                    }
                    if (nextOk) {
                        items += '<p>⬆️Before  (<code>' + safeField + '</code> = ' + nextVal + ') ' + issueLinkHtml($next) + '</p>';
                        items += '<p>' + issueSubjectHtml($next) + '</p><hr />';
                    }
                    var extraHtml =
                        '<div class="warning" style="text-align:left;">' + items + '</div>';

                    openQuickEdit(curId, fieldName, {
                        extraHtml:     extraHtml,
                        proposedValue: suggested,
                        cancelReload:  true
                    });
                }
            });
        });
    });
}
