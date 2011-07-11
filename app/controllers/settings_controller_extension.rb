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
        puts "==== fix cntrlr"
       if params["id"] == "compel_plugin"
        puts "==== fix cntrlr saving"
        p params["queries"]
        if params["queries"]
         puts "==== update"
         Query.update params["queries"].keys, params["queries"].values
        end
       else
        puts "==== fix cntrlr nonneeded"
       end
     end
   end
 end

