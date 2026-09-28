# Redmine plugin table issue
_Exported on 2/24/2026 at 16:23:55 GMT+1 from Cursor (2.4.31)_

---

**User**

@redmine_goodies/_FEATUREBOOK/featurebook/ReorderTad.md doesn't work on this table DOM Path: div#wrapper > div#main > div#content > div.i.ue tracker-24 .tatu.-2 priority-4 priority-default parent detail > div#issue_tree > form > div.auto.croll > table.li.t i.ue. odd-even view-column > thead > tr > th.cf_99
Position: top=127px, left=432px, width=96px, height=24px
HTML Element: <th class="cf_99" style="" data-cursor-element-id="cursor-el-1">🔥Pr backlog</th> 

This table is because of the plugin redmine_issue_view_columns, that replaces the subtasks tree w/ a tree. Probably it has slightly different css selectors. Because visually, it looks similar to a standard table.

---

**User**

Undo. Because 1/ on each page display => new DB hits. And 2/ that table doesn't have the "sort by" marker.

Let's do otherwise. In settings, add a new input for fields. Name: Force enablement for fields
Explanation: 
This features activates by looking at the header cell of the column: is the CF of type float? Is the column sorted by this column? For the fields here, this conditions are not checked, and the feature is forced.
Reason? E.g. if using a plugin such as "redmine_issue_view_columns" to display the subissues (of an issue) as table.

---

**User**

 works patially. icon on header: ok: DOM Path: div#wrapper > div#main > div#content > div.i.ue tracker-24 .tatu.-2 priority-4 priority-default parent detail > div#issue_tree > form > div.auto.croll > table.li.t i.ue. odd-even view-column > thead > tr > th.cf_99 > span.icon-only icon-.ort-handle .ort-handle-header
Position: top=433px, left=436px, width=16px, height=16px
HTML Element: <span class="icon-only icon-sort-handle sort-handle-header" title="This column supports drag-to-reorder" data-cursor-element-id="cursor-el-651"></span> 
icon on row: partial ok. It is on the first cell: DOM Path: div#wrapper > div#main > div#content > div.i.ue tracker-24 .tatu.-2 priority-4 priority-default parent detail > div#issue_tree > form > div.auto.croll > table.li.t i.ue. odd-even view-column > tbody.ui-.ortable > tr#issue-30105 > td.ubject > span.icon-only icon-.ort-handle .ort-handle ui-.ortable-handle
Position: top=455px, left=26px, width=16px, height=16px
HTML Element: <span class="icon-only icon-sort-handle sort-handle ui-sortable-handle" title="Drag to reorder" data-cursor-element-id="cursor-el-1"></span> . not on the good cell: DOM Path: div#wrapper > div#main > div#content > div.i.ue tracker-24 .tatu.-2 priority-4 priority-default parent detail > div#issue_tree > form > div.auto.croll > table.li.t i.ue. odd-even view-column > tbody.ui-.ortable > tr#issue-30105 > td.cf_99 float
Position: top=453px, left=432px, width=112px, height=35px
HTML Element: <td class="cf_99 float" data-cursor-element-id="cursor-el-667"></td> .
drag/drop works. But on drop: nothing happens

---

**User**

@redmine_goodies/_FEATUREBOOK/featurebook/ReorderTad.md update the spec here, w/ the new feature; a new "scenario"

---

**User**

sorry; not in the .md file; but @redmine_goodies/_FEATUREBOOK/src/ReorderTad.ts 

---

**User**

@redmine_goodies/config/locales/en.yml:51-52 you didn't respect what I said; I put again. 2 lines:

This feature activates by looking at the header cell of the column: is the CF of type float? Is the column sorted by this column? For the fields here, this conditions are not checked, and the feature is forced.
Reason? E.g. if using a plugin such as "redmine_issue_view_columns" to display the subissues (of an issue) as table.

---

**User**

I said 2 lines! You concatenated in 1 line.

---

**User**

nope; 2 separate messages; so that they are shown on 2 lines in HTML

---

**User**

@redmine_goodies/config/locales/en.yml:51-54 I put 3 lines; please adjust

---

**User**

For this mode, "Recalculate order indexes" doesn't activate. Probably because the "sort by" icon doesn't exist. Let's do like this: if we are in the "forced" mode, there may be 1 .. N fields. Consider the first one as being the "sort by".

---

