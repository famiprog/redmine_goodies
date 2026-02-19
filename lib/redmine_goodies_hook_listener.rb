class RedmineGoodiesHookListener < Redmine::Hook::ViewListener
	render_on :view_layouts_base_html_head, :partial => "redmine_goodies/global_macros"
	render_on :view_issues_context_menu_start, :partial => "redmine_goodies/quick_edit_context_menu"
end