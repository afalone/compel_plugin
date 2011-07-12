module SettingsControllerExtension
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
     base.class_eval do
       alias_method_chain :plugin, :compel_queries
     end
   end

   module InstanceMethods
     def plugin_with_compel_queries
        plugin_without_compel_queries
       if params["id"] == "compel_plugin"
        if params["queries"]
         Query.update params["queries"].keys, params["queries"].values
        end
       end
     end
   end
 end

