class RedmineGoodiesHookListener < Redmine::Hook::ViewListener
	# Reorder before global_macros so reorder.js loads first; reposition (in global_macros) must run after it.
	render_on :view_layouts_base_html_head, :partial => "redmine_goodies/reorder"
	render_on :view_layouts_base_html_head, :partial => "redmine_goodies/global_macros"
	render_on :view_issues_context_menu_start, :partial => "redmine_goodies/quick_edit_context_menu"
end