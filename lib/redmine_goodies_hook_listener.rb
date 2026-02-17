class RedmineGoodiesHookListener < Redmine::Hook::ViewListener
	render_on :view_layouts_base_html_head, :partial => "redmine_goodies/collapsible_images"
	render_on :view_issues_edit_notes_bottom, :partial => "redmine_goodies/macros_system"
	render_on :view_issues_context_menu_start, :partial => "redmine_goodies/quick_edit_context_menu"
end