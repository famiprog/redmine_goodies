class RedmineGoodiesHookListener < Redmine::Hook::ViewListener
	render_on :view_layouts_base_html_head, :partial => "redmine_goodies/collapsible_images"
end