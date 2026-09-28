# MyQuickMenuTad spec implementation
_Exported on 4/4/2026 at 08:24:13 GMT+2 from Cursor (2.6.21)_

---

**User**

@redmine_goodies/_FEATUREBOOK/src/MyQuickMenuTad.ts:1 please implement this spec

---

**User**

look the config I made and saved: DOM Path: div#wrapper > div#main > div#content > div#settings > form > div.box tabular .etting > p[1] > textarea#settings_my_quick_menu_pairs
Position: top=275px, left=323px, width=403px, height=51px
HTML Element: <textarea name="settings[my_quick_menu_pairs]" id="settings_my_quick_menu_pairs" rows="3" data-cursor-element-id="cursor-el-1"></textarea> . And it doesn't work. Look what I see: DOM Path: div#rg-my-quick-menu-popup > p.nodata
Position: top=44px, left=47px, width=233px, height=29px
HTML Element: <p class="nodata" data-cursor-element-id="cursor-el-1">Could not load menu content.</p> 

---

**User**

@\home\poweruser\.cursor\projects\home-poweruser-workspaces-redmine-cursor-code-workspace\terminals\1.txt:875-902 I think this is the log you are looking for?

---

**User**

@redmine_goodies/assets/javascripts/my_quick_menu.js:106 does this mean that it is positioned next to the link? because in mobile mode, this is not really good. because the link is somewhere in the bottom/right. So the current alignment throws the popup outside the visible area

---

**User**

ok; apply the fix

---

**User**

in mobile mode, if I click outside, the popup doesn't close

---

**User**

I'd say you need to undo the change you've made; it doesn't help at all. In mobile mode, I still cannot close the popup (if I click outside)

---

**User**

I have a page w/ this content:

# Menu1

{{include(Menu_common)}}

* Categ
  * Link 1
  * Link 2
* Categ
  * Link 1
  * Link 2

the included part i rendered correctly: DOM Path: div#wrapper > div#main > div#content > div.wiki wiki-page > p[1]
Position: top=180px, left=16px, width=720px, height=14px
HTML Element: <p data-cursor-element-id="cursor-el-1">Menu common ...</p> . However, in the menu there is an error: DOM Path: div#rg-my-quick-menu-popup > div.wiki > div.fla.h error
Position: top=73px, left=47px, width=384px, height=29px
HTML Element: <div class="flash error" data-cursor-element-id="cursor-el-1">Error executing the include macro (Page not found)</div> 

---

**User**

for this spec @redmine_goodies/_FEATUREBOOK/src/OrganizeCustomQueriesTad.ts , I want to move the link from down/this place: DOM Path: div#wrapper > div#main > div#sidebar > hr
Position: top=330px, left=773px, width=220px, height=1px
HTML Element: <hr data-cursor-element-id="cursor-el-1"></hr> DOM Path: div#wrapper > div#main > div#sidebar > p > a
Position: top=343px, left=773px, width=150px, height=14px
HTML Element: <a href="#" data-cursor-element-id="cursor-el-274">Organize custom queries</a> to up, before DOM Path: div#wrapper > div#main > div#sidebar > h3
Position: top=121px, left=773px, width=220px, height=19px
HTML Element: <h3 data-cursor-element-id="cursor-el-192">Custom queries</h3> . We'll have link, hr, original content

---

**User**

@redmine_goodies/assets/javascripts/organize_custom_queries.js:20-21 no need; we'll always find something;

however, please change the detection mode of the first link. E.g. if there are "my custom queries", then the first link is DOM Path: div#wrapper > div#main > div#sidebar > h3[0]
Position: top=121px, left=773px, width=220px, height=19px
HTML Element: <h3 data-cursor-element-id="cursor-el-1">My custom queries</h3> . And if the user doesn't have EN as language, probably it will fail. So search e.g. before the first header in element DOM Path: div#wrapper > div#main > div#sidebar
Position: top=107px, left=752px, width=249px, height=2404px
HTML Element: <div id="sidebar" data-cursor-element-id="cursor-el-191">My custom queries testClear Organize custom queries Custom queries 0 My tasks to review 1 My tasks / recurent 2.1 NEW My tasks / personal backlog 2.2 My tasks worked yesterday 2 My tasks (w/o recure</div> 

---

**User**

@redmine_goodies/assets/javascripts/reorder.js:188-189 When sending data to sever from javascript, Rails has a function called Rails.ajax that automatically adds the csrfToken. Can you refactor this code so it does the same thing? Or use an alternative for forms?

---

**User**

@redmine_goodies/_FEATUREBOOK/src/ReorderTad.ts:24-29 spec changed; new shortcut

---

**User**

read what I gave you

---

**User**

you  got it wrong; undo your modif; the new spec = new shortcut = ctrl + alt + r

---

**User**

and the label?

---

**User**

@redmine_goodies/config/locales/en.yml:77-78 @redmine_goodies/config/locales/en.yml:71-72 DRY. Use only one key

---

