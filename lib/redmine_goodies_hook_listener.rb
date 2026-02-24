class RedmineGoodiesHookListener < Redmine::Hook::ViewListener
	# Both partials must be passed to a single render_on call: Ruby's define_method replaces any previous
	# method with the same name, so two separate render_on calls for the same hook would silently discard
	# the first one.
	render_on :view_layouts_base_html_head,
	          {:partial => "redmine_goodies/reorder"},
	          {:partial => "redmine_goodies/global_macros"}
	render_on :view_issues_context_menu_start, :partial => "redmine_goodies/context_menu"
end