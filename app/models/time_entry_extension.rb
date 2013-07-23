module TimeEntryExtension
 def self.included(base)
  #base.extend(TimeEntryExtension::ClassMethods)
  #base.send(:include, IssueExtension::InstanceMethods)
  base.class_eval do
   attr_protected :user_id, :project_id, :tyear, :tmonth, :tweek, :as => :default
   attr_protected :tyear, :tmonth, :tweek, :as => :robot
   #attr_protected :project_id, :user_id, :tyear, :tmonth, :tweek
   #after_save :reorder_positions
   #before_save :store_work_dates
   #before_save :init_position
   #before_validation :apply_issue_close_date
   #validate :check_assigned_to_validity_in_status
   #protected :check_assigned_to_validity_in_status
   #alias_method_chain :assignable_versions, :permission_edit
   #alias_method_chain :validate, :permission_edit
   #safe_attributes 'due_task_date',
   # :if => lambda {|issue, user| issue.new_record? || user.allowed_to?(:edit_issues, issue.project) }
   #safe_attributes 'due_task_date',
   # :if => lambda {|issue, user| issue.new_statuses_allowed_to(user).any? }
  end
 end

end
