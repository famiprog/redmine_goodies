class RedmineGoodiesHookListener < Redmine::Hook::ViewListener
	render_on :view_layouts_base_html_head, :partial => "redmine_goodies/global_macros"
	render_on :view_issues_edit_notes_bottom, :partial => "redmine_goodies/issue_macros"
end