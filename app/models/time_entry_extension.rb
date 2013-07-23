module TimeEntryExtension
 def self.included(base)
  base.class_eval do
   attr_protected :user_id, :project_id, :tyear, :tmonth, :tweek, :as => :default
   attr_protected :tyear, :tmonth, :tweek, :as => :robot
  end
 end

end
