Redmine::Plugin.register :redmine_goodies do
    name 'Redmine goodies'
    author 'famiprog'
    description 'For detailed documentation see the link below.'
    version '1.0.0-SNAPSHOT-2'
    url 'https://github.com/famiprog/redmine_goodies'
    author_url 'https://github.com/famiprog'

    settings :default => {'empty' => true, 
                            :remove_lazy_loading => '1',
                            :collapsible_images => '0'}, 
             :partial => 'settings/redmine_goodies_settings'
  
    require File.expand_path('lib/redmine_goodies_hook_listener', __dir__)
    require File.expand_path('lib/redmine_goodies_settings', __dir__)
    ApplicationController.send(:include, RedmineGoodiesControllerPatch)
end
