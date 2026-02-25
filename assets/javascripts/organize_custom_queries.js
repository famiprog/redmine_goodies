jQuery(document).ready(function() {
    var $ = jQuery;

    var settings = window.RedmineGoodiesOrganizeCQSettings;
    if (!settings || !settings.projectId) { return; }

    var $sidebar = $('#sidebar');
    if ($sidebar.length === 0) { return; }

    var $allQueryUls = $sidebar.find('ul.queries');
    if ($allQueryUls.length === 0) { return; }

    // Inject <hr> + "Organize custom queries" link after the last ul.queries
    var $link = $('<a>').attr('href', '#').text(settings.linkText);
    var $linkP = $('<p>').append($link);
    $allQueryUls.last().after($('<br>'), $('<hr>'), $linkP);

    $link.on('click', function(e) {
        e.preventDefault();
        $linkP.text('\u2026');  // "…" loading indicator

        $.ajax({
            url:      settings.apiUrl,
            type:     'GET',
            data:     { project_id: settings.projectId },
            dataType: 'json',
            success: function(data) {
                organizeSidebar(
                    data.public_global_ids  || [],
                    data.private_global_ids || []
                );
            },
            error: function() {
                $linkP.text(settings.linkText);   // restore so user can retry
                $linkP.prepend($link);
            }
        });
    });

    // ---- helpers ----

    function findH3ByText(text) {
        var $found = null;
        $sidebar.find('h3').each(function() {
            if ($.trim($(this).text()) === text) { $found = $(this); return false; }
        });
        return $found;
    }

    // Splits one sidebar section (h3 + ul.queries) into a project-scoped part
    // and an all-projects part. Items whose query_id is in globalIds go to the
    // all-projects group and get an (all proj) badge link.
    function splitSection($h3, labelThisProject, labelAllProjects, globalIds) {
        var $ul = $h3.next('ul.queries');
        if ($ul.length === 0) { return; }

        var $projectItems = [];
        var $globalItems  = [];

        $ul.find('> li').each(function() {
            var $li  = $(this);
            var href = $li.find('a').first().attr('href') || '';
            var m    = href.match(/[?&]query_id=(\d+)/);
            var qId  = m ? parseInt(m[1], 10) : null;

            if (qId !== null && globalIds.indexOf(qId) !== -1) {
                $globalItems.push($li.detach());
            } else {
                $projectItems.push($li.detach());
            }
        });

        var $newContent = $('<div>');

        if ($projectItems.length > 0) {
            var $h3p = $('<h3>').text(labelThisProject);
            var $ulp = $('<ul>').addClass('queries');
            $projectItems.forEach(function($li) { $ulp.append($li); });
            $newContent.append($h3p, $ulp);
        }

        if ($globalItems.length > 0) {
            var $h3g = $('<h3>').text(labelAllProjects);
            var $ulg = $('<ul>').addClass('queries');
            $globalItems.forEach(function($li) {
                var href = $li.find('a').first().attr('href') || '';
                var m    = href.match(/[?&]query_id=(\d+)/);
                if (m) {
                    var $badge = $('<a>').attr({ href: '/issues?query_id=' + m[1], title: settings.iconHintText })
                        .append($('<small>').text(settings.badgeText).css({ marginLeft: '4px', color: "gray" }));
                    $li.append($badge);
                }
                $ulg.append($li);
            });
            $newContent.append($h3g, $ulg);
        }

        // Swap h3 + ul for the new content in-place
        var $placeholder = $('<span>');
        $h3.replaceWith($placeholder);
        $ul.remove();
        $placeholder.replaceWith($newContent.children());
    }

    function organizeSidebar(publicGlobalIds, privateGlobalIds) {
        var $myH3 = findH3ByText(settings.labelMyQueries);
        if ($myH3) {
            splitSection(
                $myH3,
                settings.labelMyQueries + ' ' + settings.suffixThisProject,
                settings.labelMyQueries + ' ' + settings.suffixAllProjects,
                privateGlobalIds
            );
        }

        var $cqH3 = findH3ByText(settings.labelCustomQueries);
        if ($cqH3) {
            splitSection(
                $cqH3,
                settings.labelCustomQueries + ' ' + settings.suffixThisProject,
                settings.labelCustomQueries + ' ' + settings.suffixAllProjects,
                publicGlobalIds
            );
        }

        // Replace the link paragraph with the hint text
        var $hint = $('<p>').css({ color: 'gray' })
            .append($('<span>').text(settings.badgeText))
            .append(document.createTextNode(': ' + settings.iconHintText));
        $linkP.replaceWith($hint);
    }
});
