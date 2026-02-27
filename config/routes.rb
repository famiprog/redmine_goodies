get 'redmine_goodies_organize_cq', :to => 'redmine_goodies_organize_cq#index', :as => 'redmine_goodies_organize_cq'
get 'redmine_goodies_edit_field', :to => 'redmine_goodies_quick_edit#edit_field', :as => 'redmine_goodies_edit_field'
post 'redmine_goodies_update_field', :to => 'redmine_goodies_quick_edit#update_field', :as => 'redmine_goodies_update_field'
post 'redmine_goodies_recalculate_field', :to => 'redmine_goodies_reorder#recalculate_field', :as => 'redmine_goodies_recalculate_field'
get  'redmine_goodies_activate_reorder',  :to => 'redmine_goodies_reorder#activate_reorder',  :as => 'redmine_goodies_activate_reorder'

