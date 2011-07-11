require 'redmine'

RAILS_DEFAULT_LOGGER.info 'Starting COMPEL plugin for RedMine'

Redmine::Plugin.register :compel_plugin do

  name 'COMPEL'
  author 'uzianov@gmail.com'
  description 'custom add-on'
  version '2.0.0'

  # settings :default => {'sample_setting' => 'value', 'foo'=>'bar'}, :partial => 'settings/sample_plugin_settings'

  project_module :compel do
    permission :compel_pos_orpo, { :compel => [:orpo] }, :require => :member
    permission :compel_pos_orit, { :compel => [:orit] }, :require => :member
    permission :compel_pos_view, { :compel => [:view] }, :require => :member
  end

  # Мои задачи
  menu :top_menu, :compel_my, { :controller => :issues, :action => :index, :query_id => 45 }, :caption => "Мои задачи", :if => Proc.new { Issue.exists?({:assigned_to_id => User.current.id}) }

  # Очередь задач
  menu :top_menu, :compel_pos_view, { :controller => :issues, :action => :index, :query_id => 46 }, :caption => 'Моя очередь', :if => Proc.new { User.current.allowed_to?(:compel_pos_view, nil, :global => true) }

  settings :default => {}, :partial => 'settings/compel_settings'
  # Активные задачи
  menu :top_menu, :issue_view_all, { :controller => :issues, :action => :index, :set_filter => 1 }, :caption => :label_issue_view_all

  # Новые задачи
  menu :top_menu, :compel_new, { :controller => :issues, :action => :index, :query_id => 1 },  :caption => 'Новые задачи'

  menu :application_menu, :compel_pos_orpo, { :controller => :reorder, :action => :developer  }, :caption => 'Очередь ОРПО', :if => Proc.new { User.current.allowed_to?(:compel_pos_orpo, nil, :global => true) }  
  menu :application_menu, :compel_pos_orit, { :controller => :reorder, :action => :ideveloper }, :caption => 'Очередь ОРИТ', :if => Proc.new { User.current.allowed_to?(:compel_pos_orit, nil, :global => true) } 

#  menu :project_menu, :reorder_project, { :controller => :reorder, :action => :project }, :caption => :label_reorder_project, :before => :new_issue, :if => Proc.new { |p| User.current.allowed_to?(:reorder_project, p) || User.current.admin? }

end


#require "dispatcher"
#require 'settings_controller_extension'
#unless SettingsController.included_modules.include? SettingsControllerExtension
# Dispatcher.to_prepare do
#  SettingsController.send(:include, SettingsControllerExtension)
# end
#end
#ActiveSupport::Dependencies.load_paths << "#{RAILS_ROOT}/vendor/plugins/compel_plugin/extra"
$LOAD_PATH << "#{RAILS_ROOT}/vendor/plugins/compel_plugin/extra"
