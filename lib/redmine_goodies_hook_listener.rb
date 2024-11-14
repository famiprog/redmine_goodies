class RedmineGoodiesHookListener < Redmine::Hook::ViewListener
	render_on :view_layouts_base_html_head, :partial => "redmine_goodies/collapsible_images"
	render_on :view_issues_edit_notes_bottom, :partial => "redmine_goodies/questions_system"
end