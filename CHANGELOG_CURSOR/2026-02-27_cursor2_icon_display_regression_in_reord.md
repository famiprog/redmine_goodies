# Icon display regression in reorder issues
_Exported on 2/27/2026 at 12:43:23 GMT+1 from Cursor (2.5.25)_

---

**User**

There is a regression. When I click on "Reorder issues": 
1/ icons appear in the header cells for the eligible coluns; this is OK
2/ icons also appear for the cells of all this columns; this is not OK. Only the one w/ "sort" should have them

---

**User**

you seem stuck; 
I restarted the docker container:
in the browser I show the issue; e.g. shouldn't appear: DOM Path: div#wrapper > div#main > div#content > form[1] > div.auto.croll > table.li.t i.ue. odd-even .ort-by-cf-153 .ort-a.c > tbody.ui-.ortable > tr#issue-40521 > td.cf_99 float > span.icon-only icon-.ort-handle .ort-handle ui-.ortable-handle
Position: top=341px, left=525px, width=16px, height=16px
HTML Element: <span class="icon-only icon-sort-handle sort-handle ui-sortable-handle" title="Drag to reorder" data-cursor-element-id="cursor-el-1"></span> 

---

**User**

DOM Path: div#wrapper > div#main > div#content > form[1] > div.auto.croll > table.li.t i.ue. odd-even .ort-by-cf-153 .ort-a.c > tbody.ui-.ortable > tr#issue-40536 > td.cf_99 float > span.icon-only icon-.ort-handle .ort-handle ui-.ortable-handle
Position: top=308px, left=525px, width=16px, height=16px
HTML Element: <span class="icon-only icon-sort-handle sort-handle ui-sortable-handle" title="Drag to reorder" data-cursor-element-id="cursor-el-2304"></span> same issue!

---

**User**

I restarted; same issue DOM Path: div#wrapper > div#main > div#content > form[1] > div.auto.croll > table.li.t i.ue. odd-even .ort-by-cf-153 .ort-a.c > tbody.ui-.ortable > tr#issue-40536 > td.cf_99 float > span.icon-only icon-.ort-handle .ort-handle ui-.ortable-handle
Position: top=308px, left=525px, width=16px, height=16px
HTML Element: <span class="icon-only icon-sort-handle sort-handle ui-sortable-handle" title="Drag to reorder" data-cursor-element-id="cursor-el-2921"></span> 

---

**User**

Let's add a shortcut: CTRL + R that activates the "reorder issues" feature.

---

**User**

I don't understand why in the shortcut case it's so complicated?

I mean I see "the simple path": @redmine_goodies/assets/javascripts/reorder.js:88-92 

But what about the code after that?

Could we have a shorter/clearner approach?

---

**User**

I still don't like it;

I'd like a function activateReorder()
called from the menu; called from the button event handler

---

**User**

@redmine_goodies/assets/javascripts/reorder.js:81 but even this; I don't want 2 modes of finding the table: one for menu action, one for shortcut

---

**User**

@redmine_goodies/app/views/redmine_goodies/_context_menu.html.erb:50 can we take this string from the plugin config? so that I don't redefine it in en.yml?

---

