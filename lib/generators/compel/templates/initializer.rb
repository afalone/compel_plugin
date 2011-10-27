#require 'dispatcher'
#require 'settings_controller_extension'
 
Dispatcher.to_prepare do
 unless Issue.included_modules.include? IssueExtension
  Issue.send(:include, IssueExtension)
 end
 unless MyController.included_modules.include? MyControllerExtension
  MyController.send(:include, MyControllerExtension)
  puts "my_controller ready"
 end
 unless ApplicationHelper.included_modules.include? ApplicationHelperExtension
  ApplicationHelper.send(:include, ApplicationHelperExtension)
  puts "application_helper ready"
 end
 unless SettingsController.included_modules.include? SettingsControllerExtension
  SettingsController.send(:include, SettingsControllerExtension)
RAILS_DEFAULT_LOGGER.info "compel ready"
 end
end
