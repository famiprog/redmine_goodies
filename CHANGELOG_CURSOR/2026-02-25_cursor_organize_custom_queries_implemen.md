# Organize custom queries implementation
_Exported on 2/25/2026 at 12:21:52 GMT+1 from Cursor (2.4.31)_

---

**User**

Please implement @redmine_goodies/_FEATUREBOOK/src/OrganizeCustomQueriesTad.ts .

Use the "modify the DOM at render" technique cf. @redmine_crispico_plugin/doc/README-old.md:219-249 

---

**User**

1/ replace the icon w a text: (all proj)
2/ add settings. A checkbox to enable/disable

---

**User**

1/ let's apply this "split" also for "My custom queries"
2/ 
@redmine_goodies/app/views/redmine_goodies/_organize_custom_queries.html.erb:3-13 I don't like this; it adds a new query to each page render. Let's rearchitecture the feature.

We don't do nothing server side (besides including the js). We have at the end of the CQ list, after the <hr> a link: Organize custom queries

on click: server code is executed to obtain the ids for global queries. And the dom manipulation is made.

So everything happens if the user clicks.

---

**User**

dry

1/ we have same text here: @redmine_goodies/config/locales/en.yml:64-65 @redmine_goodies/config/locales/en.yml:67-68 
2/ duplicated text @redmine_goodies/config/locales/en.yml:68-71 

you entered in endless loop; continue

---

