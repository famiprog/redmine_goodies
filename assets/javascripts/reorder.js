// Find tables that have a sorted float custom-field column (cf_XX float + icon-sorted-*)
// and add a drag handle in each body cell for that column.
// On drop: open the existing Quick Edit modal with neighbor context and suggested value.

if (typeof jQuery !== 'undefined') {
    jQuery(document).ready(function() {
        var $ = jQuery;

        var reorderSettings = window.RedmineGoodiesReorderSettings;
        var reorderI18n = window.RedmineGoodiesReorderI18n;
        if (!reorderSettings.enableIssueReorder) {
            return;
        }

        var enableFor = (reorderSettings.enableFor || 'any').toLowerCase();
        // cfEditability: server-computed map of { "cf_N": true/false } using the same
        // field_editable_by? check as Quick Edit (edit_issues permission + workflow).
        // An absent key means we have no server data for that CF (e.g. non-issue pages)
        // and we default to allowing the icon.
        var cfEditability = reorderSettings.cfEditability || {};
        // specifiedFields: array of { cf_id, caption } from server (DRY with quick edit field matching)
        var specifiedFields = reorderSettings.specifiedFields || [];

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

        // ---- Recalculate order indexes ----
        // Registered once outside the table loop so it fires even when no table is currently
        // sorted by a reorderable column (scenario 2: show the error popup).
        $(document).on('click', '#redmine-goodies-recalculate-link', function(e) {
            e.preventDefault();

            var $link = $(this);
            var rawIds = $link.data('issue-ids') || '';
            var issueIds = String(rawIds).split(',').filter(Boolean);
            var recalculateUrl = $link.data('recalculate-url') || '/redmine_goodies_recalculate_field';
            var csrfToken = $('meta[name="csrf-token"]').attr('content') || '';

            // Find the first table column that has a reorder header marker AND is currently sorted.
            var sortedColumn = null;
            $('table').each(function() {
                var $tbl = $(this);
                $tbl.find('thead tr').first().find('th').each(function(ci) {
                    var $th = $(this);
                    if ($th.find('.sort-handle-header').length > 0 &&
                        $th.find('a[class*="icon-sorted-"]').length > 0) {
                        sortedColumn = {
                            fieldName: $.trim($th.find('a').first().text()),
                            colIndex: ci,
                            $table: $tbl
                        };
                        return false;
                    }
                });
                if (sortedColumn) { return false; }
            });

            // Collect selected issue rows in DOM (visual) order, restricted to the context-menu selection.
            var idSet = {};
            issueIds.forEach(function(id) { idSet[String(id)] = true; });
            var orderedIds = [];
            $('table tbody tr[id^="issue-"]').each(function() {
                var id = ($(this).attr('id') || '').replace(/\D/g, '');
                if (id && idSet[id]) { orderedIds.push(id); }
            });

            var $modal = $('<div>');
            var titleText = reorderI18n.recalcTitle;
            if (titleText) {
                var $header = $('<div>').addClass('modal-header');
                $header.append($('<h3>').addClass('title').css({ marginTop: 0 }).text(titleText));
                $modal.append($header);
            }

            if (sortedColumn && orderedIds.length >= 2) {
                var n = orderedIds.length;
                var before = reorderI18n.recalcBefore;
                var after = reorderI18n.recalcAfter;

                before = before.split('%{count}').join(n);
                after = after.split('%{count}').join(n);

                var $p = $('<p>');
                if (before) {
                    $p.append(document.createTextNode(before + ' '));
                }
                $p.append($('<code>').text(sortedColumn.fieldName));
                if (after) {
                    $p.append(document.createTextNode(after));
                }
                $modal.append($p);

                var $form = $('<form>').attr({ method: 'POST', action: recalculateUrl }).hide();
                $form.append($('<input>').attr({ type: 'hidden', name: 'authenticity_token', value: csrfToken }));
                $form.append($('<input>').attr({ type: 'hidden', name: 'field_name', value: sortedColumn.fieldName }));
                $form.append($('<input>').attr({ type: 'hidden', name: 'ids', value: orderedIds.join(',') }));
                $form.append($('<input>').attr({ type: 'hidden', name: 'js_position', value: $(window).scrollTop() }));
                $modal.append($form);

                var okLabel = reorderI18n.ok;
                var cancelLabel = reorderI18n.cancel;
                var $ok = $('<button>').css({ height: '28px', boxSizing: 'border-box' }).text(okLabel);
                var $cancel = $('<button>').css({ height: '28px', boxSizing: 'border-box' }).text(cancelLabel);
                $ok.on('click', function() { $form.submit(); });
                $cancel.on('click', function() { hideModal(this); });
                var $btns = $('<div>').addClass('buttons').css({ textAlign: 'center', marginBottom: 0 });
                $btns.append($ok).append(' ').append($cancel);
                $modal.append($btns);
            } else {
                var intro = reorderI18n.recalcIntro;
                var cond1 = reorderI18n.recalcCond1;
                var cond2 = reorderI18n.recalcCond2;
                var $ol = $('<ol>');
                if (cond1) { $ol.append($('<li>').text(cond1)); }
                if (cond2) { $ol.append($('<li>').text(cond2)); }
                if (intro) { $modal.append($('<p>').text(intro)); }
                $modal.append($ol);

                var okLabel2 = reorderI18n.ok;
                var $okBtn = $('<button>').css({ height: '28px', boxSizing: 'border-box' }).text(okLabel2);
                $okBtn.on('click', function() { hideModal(this); });
                $modal.append(
                    $('<div>').addClass('buttons').css({ textAlign: 'center', marginBottom: 0 }).append($okBtn)
                );
            }

            window.RedmineGoodiesModal.show($modal, '480px');
        });
        // ---- end Recalculate order indexes ----

        $('table').each(function() {
            var $table = $(this);
            var $headerRow = $table.find('thead tr').first();
            if ($headerRow.length === 0) { return; }

            // Columns that conceptually support reordering (float CF), regardless of current sort state
            var eligibleColumnIndexes = [];
            // Columns that are both eligible, allowed by settings, and currently sorted by that CF; only these get drag handles in body cells
            var targetColumnIndexes = [];

            $headerRow.find('th').each(function(colIndex) {
                var $th = $(this);
                var classAttr = $th.attr('class') || '';
                // Must have cf_XX and float in class list to be eligible
                if (!/cf_\d+/.test(classAttr) || classAttr.indexOf('float') === -1) { return; }

                // Header text and cf_N from th (same identifiers as quick edit uses server-side)
                var headerText = $.trim($th.find('a').first().text() || '');
                var headerKey = headerText.toLowerCase();
                var cfMatch = classAttr.match(/(cf_\d+)/i);
                var cfId = cfMatch ? cfMatch[1].toLowerCase() : '';

                // Match using server-resolved list (DRY with quick edit: cf_id and caption)
                function columnInSpecifiedList() {
                    for (var i = 0; i < specifiedFields.length; i++) {
                        var spec = specifiedFields[i];
                        var specCfId = (spec.cf_id || '').toLowerCase();
                        var specCaption = (spec.caption || '').toLowerCase();
                        if (cfId && specCfId && cfId === specCfId) { return true; }
                        if (headerKey && specCaption && headerKey === specCaption) { return true; }
                    }
                    return false;
                }

                // Enforce Enable for / Specified fields rules
                var allowed = true;
                if (enableFor === 'whitelist') {
                    allowed = columnInSpecifiedList();
                } else if (enableFor === 'blacklist') {
                    allowed = !columnInSpecifiedList();
                }
                if (!allowed) { return; }

                // Reuse the same permission gate as Quick Edit (field_editable_by?):
                // if the server computed editability for this CF and it is false, skip it.
                if (cfId && cfEditability.hasOwnProperty(cfId) && !cfEditability[cfId]) { return; }

                eligibleColumnIndexes.push(colIndex);

                // Add a passive green marker in the header to hint that this column supports reordering.
                // It does not have any click behavior; the actual drag handle lives in the body cells.
                if ($th.find('.sort-handle-header').length === 0) {
                    var $headerHandle = $('<span>', {
                        'class': 'icon-only icon-sort-handle sort-handle-header',
                        'title': reorderI18n.headerSupportsReorder || 'This column supports drag-to-reorder'
                    });
                    $th.prepend($headerHandle);
                }

                // Only columns that are currently sorted by this CF get active drag handles in the body cells.
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
                        'title': reorderI18n.dragToReorder || 'Drag to reorder'
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
                        suggested = Math.floor(nextVal - 1);   // dropped at the top: e.g. 2 or 2.5 => 1
                    } else if (!hasNext && prevOk) {
                        suggested = Math.floor(prevVal) + 1;   // dropped at the bottom: e.g. 2 or 2.5 => 3
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
