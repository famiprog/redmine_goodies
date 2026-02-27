# Performance impact review of redmine_goodies branch
_Exported on 2/27/2026 at 12:42:47 GMT+1 from Cursor (2.5.25)_

---

**User**

The perf impact for issue list: isn't it proportional to the amount of issues also? This is what I observer

---

**User**

First measure: let's not execute the code any more on each render. We'll do "on demand". Add a new context menu action: Reorder issues (cf. @redmine_goodies/config/locales/en.yml:41-42 . And on click it happens the JS code, which calls server code for needed info.

---

**User**

now the perf impact is only on button click; 
however, there is still an iteration done per task? 
I assume that this is because the read-only-ness is per project (depending on role); and per tracker. Correct? 

---

**User**

where is the memoization exactly?

---

**User**

So the "memoization" was "whishfull thinking".
Please implement this in our method. I don't know if there is a memoization lib or magic or pattern (like there are some in JS), or if we need to implement it w/ maps. If maps: don't use multi-level. Use only one level, and the key is a concat of participants.

---

**User**

@redmine_goodies/lib/redmine_goodies_quick_edit_helper.rb:111 this is a function from redmine? or is it ours?

---

**User**

I observe a regression. When I click on the action, it adds icons in the cells also for columns eligible, but not "sorted by". E.g. I have 2 columns w/ cells w/ icon. I should have only one (if sort by) or zero if sort by by other column. 

Of course: the header arrows should be there for all columns.

---

