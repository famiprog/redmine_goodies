# Performance impact review of redmine_goodies branch
_Exported on 2/24/2026 at 11:43:45 GMT+1 from Cursor (2.4.31)_

---

**User**

please review the code from redmine_goodies, this branch (compared to main). Does it produce a performance impact for normal usage (e.g. on loading the screen w/ issues or issue editor)? 

---

<details>
<summary>Cursor</summary>

**Cursor**

Now let me check the helper methods that run on every page load:

Now I have everything I need for a thorough assessment. Here is my analysis.

---

## Performance review — `cristi-RM40442-reorder` vs `main`

### What runs on every page load (the critical path)

The new `_reorder.html.erb` partial is injected into the `<head>` of **every page** via `view_layouts_base_html_head`. It does two things on every request:

**1. `reorder_specified_float_cfs` is always called** (even on non-issue pages like the dashboard or admin panel):

```40:23:app/views/redmine_goodies/_reorder.html.erb
specifiedFields: <%= raw RedmineGoodiesQuickEditHelper.reorder_specified_float_cfs(Setting.plugin_redmine_goodies[:reorder_specified_fields]).to_json %>
```

This calls `get_list_of_fields` which calls `IssueQuery.new.available_columns` — a query against `CustomField`. With the **default setting of `reorder_specified_fields = ''`**, `parse_fields_list` returns `[]` and the method exits early, so this is a no-op in practice. If the setting is filled in, it becomes a real DB query on every single page.

**2. When `@issues.present?`, a deeper loop runs** — this fires on the issues list and issue editor:

```7:17:app/views/redmine_goodies/_reorder.html.erb
if @issues.present?
  I18n.with_locale(:en) do
    IssueQuery.new.available_columns.each do |col|
      next unless col.is_a?(QueryCustomFieldColumn) && col.custom_field.field_format == 'float'
      key = "cf_#{col.custom_field.id}"
      reorder_cf_editability[key] = RedmineGoodiesQuickEditHelper.field_editable_by?(col, @issues, User.current)
    end
  end
end
```

For every float CF in the whole system, `field_editable_by?` is called. Inside that method:

```82:84:lib/redmine_goodies_quick_edit_helper.rb
# Workflow field permissions: the field must not be read-only on any of the issues
issues.none? { |issue| issue.read_only_attribute_names(user).include?(attr_name) }
```

`read_only_attribute_names` is called once per issue in `@issues` per float CF. On the issues list with 25 rows and 3 float CFs, that's ~75 calls. Redmine does cache the underlying `WorkflowPermission` query within a request, but constructing the result set is still O(issues × float_CFs) work added to every issues-list render.

---

### On the issue editor specifically

`@issues` is a 1-element array, so the loop is just `1 × N_float_CFs`. This is negligible — no real impact.

---

### JS side

The two new JS files (`utils.js`, `reorder.js`) are served through the asset pipeline and browser-cached after the first load. The `document.ready` handler only does **DOM inspection** — it never fires a network request on page load. Zero performance impact there.

---

### Summary

| Scenario | Impact | Notes |
|---|---|---|
| Non-issue pages (dashboard, admin, etc.) | **None** (default config) | `reorder_specified_float_cfs` exits early when setting is empty |
| Issue editor (single issue) | **Negligible** | 1 issue × N float CFs |
| Issues list page | **Mild** | O(page_size × N_float_CFs) extra `read_only_attribute_names` calls on each render |
| JS on page load | **None** | DOM-only, no extra AJAX |
| Context menu open | **Same as before** | The new "Redmine Goodies" submenu item is just a static link |

**The only real concern is the issues list with a large page size and many float CFs.** The `IssueQuery.new.available_columns` call inside `_reorder.html.erb` also runs without project scoping, meaning it fetches all float CFs globally — not just those visible on the current page.

**One concrete suggestion:** the editability map in `_reorder.html.erb` could be gated behind `RedmineGoodiesSettings.enable_issue_reorder?`, so the loop is skipped entirely when the feature is disabled:

```ruby
if @issues.present? && RedmineGoodiesSettings.enable_issue_reorder?
  # ... the IssueQuery loop
end
```

Right now if an admin turns off `enable_issue_reorder`, the JS bails out early (`if (!reorderSettings.enableIssueReorder) return;`) but the server-side Ruby loop **still runs** and still populates `cfEditability` needlessly.


</details>