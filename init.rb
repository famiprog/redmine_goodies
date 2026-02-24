Redmine::Plugin.register :redmine_goodies do
    name 'Redmine Goodies'
    author 'famiprog'
    description 'For detailed documentation see the link below.'
    version '2.1.0-SNAPSHOT'
    url 'https://github.com/famiprog/redmine_goodies'
    author_url 'https://github.com/famiprog'

    settings :default => {'empty' => true, 
                            :remove_lazy_loading => '1',
                            :collapsible_images => '0',
                            :reposition_context_submenu => '1',
                            :context_submenu_max_height => '',
                            :fields_to_quick_edit => '',
                            :add_parent_to_quick_edit => '0',
                            :enable_issue_reorder => '1',
                            :reorder_enable_for => 'any',
                            :reorder_specified_fields => ''}, 
             :partial => 'settings/redmine_goodies_settings'
  
    require File.expand_path('lib/redmine_goodies_hook_listener', __dir__)
    require File.expand_path('lib/redmine_goodies_settings', __dir__)
    require File.expand_path('lib/redmine_goodies_quick_edit_helper', __dir__)
    require File.expand_path('lib/redmine_goodies_macros', __dir__)
    Redmine::Hook::Helper.include QuestionsSystemHelper
    ApplicationController.send(:include, RedmineGoodiesControllerPatch)
end
