#require 'dispatcher'
#require 'settings_controller_extension'
 
Dispatcher.to_prepare do
 unless SettingsController.included_modules.include? SettingsControllerExtension
  SettingsController.send(:include, SettingsControllerExtension)
RAILS_DEFAULT_LOGGER.info "compel ready"
 end
end
puts "compel ready"
