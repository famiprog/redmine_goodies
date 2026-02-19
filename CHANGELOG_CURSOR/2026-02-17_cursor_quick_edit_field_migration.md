# Quick edit field migration
_Exported on 2/17/2026 at 13:32:42 GMT+1 from Cursor (2.4.31)_

---

**User**

there is a feature in redmine_crispico_plugin / Fields to show in quick edit menu

That code does: shows a popup Quick edit field. W/ an input populated w/ the current value. On OK, that issue/field is updated

I want to migrate it in the redmine_goodies plugin. Instead of the RCP menu, we'll have a Quick edit field menu. I want the feature to work pretty much the same. Including the settings. Including "parent task"

---

**User**

please continue and finish

---

**User**

there is no context menu "Quick edit field"

---

**User**

works; but the migration is partial. redmine_goodies needs redmine_crispico_plugin: for code and settings, etc.

Please migrate ALL. redmine_goodies should be able to provide this feature alone.

---

**User**

I still see the config section in the old plugin. It contains: 

Status update, 🕝ETUS (est time until stop), 🔥Pr backlog, 🔥Pr dev, Pr reviewer, Own tasks index.

And the "new plugin" seems to take these from there. Not OK. the 2 plugins need to be independent 100%

---

**User**

1/ when having removed the settings from the old plugin, some HTML issue appeared. Issue type to show radar button on + it's combo box are rendered ugly in the left side

2/ Quick edit context menu: show it even if there are no fields configured. Add an entry in the context menu 

Nothing configured. Please use the plugin's configuration page.

---

**User**

please double check if you have removed from redmine_crispico_plugin everything that you migrated; at first glance, I'd say you didn't

---

**User**

locale keys: why keep them in the old place?

---

**User**

@redmine_goodies/config/locales/en.yml:19-22 these are still used in the old plugin?

---

**User**

I see an issue. When changing the parent of the task, the name of that task is recalculated (to include the parent name as prefix).

If I use the context menu / Parent task: the parent task changes, but the name doesn't change.

Maybe this "rename task on parent change" was not generic enough. And in the old impl, the context menu action was explicitly invoking the "rename ..." logic. This is a guess, not a certitude

---

**User**

That means that if I update the parent from another piece of code: I'll have the same issue. Maybe same applies for API? If someone changes the parent from the API => name is not updated?

Can't you make the solution more robust for such cases? I.e. modif in the crispico plugin.

---

**User**

can't we use the IssueController from the context menu?

---

**User**

did the old code contain a block similar to one that you've just added?

---

