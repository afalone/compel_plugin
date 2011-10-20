module IssueExtension
 def self.included(base)
  base.extend(IssueExtension::ClassMethods)
  base.send(:include, IssueExtension::InstanceMethods)
  base.class_eval do
   after_save :reorder_positions
   before_save :init_position
   before_validation :apply_issue_close_date
   validate :check_assigned_to_validity_in_status
   protected :check_assigned_to_validity_in_status
   alias_method_chain :assignable_versions, :permission_edit
   alias_method_chain :validate, :permission_edit
  end
 end

 module ClassMethods
  def get_ordered_for_project(project_id)
   find(
    :all,
    :conditions => { :status_id => 1, :project_id => project_id},
    :order => "position_for_project IS NULL, position_for_project, #{Issue.table_name}.id DESC")
  end

  def get_ordered_for_user(user_id)
   find(:all,
    :include => :status,
    :conditions => ["#{IssueStatus.table_name}.is_closed = ? AND assigned_to_id = ?", false, user_id],
    :order => "position_for_user IS NULL, position_for_user, #{Issue.table_name}.id DESC")
  end


 end

 module InstanceMethods
  def reorder_positions
   if self.assigned_to_id_changed? and self.assigned_to_id_was and self.position_for_user_was
    rebuild_position_for_user(assigned_to_id_was)
   end
   if self.position_for_user
    rebuild_position_for_user(assigned_to_id)
   end
  end

  def init_position
   if self.assigned_to_id_changed? and self.assigned_to_id
    self.position_for_user = self.calc_position_for_user
   end
   if new_record? and self.status_id == 1
    self.assigned_to_id = nil
   end
  end

  def calc_position_for_user
     max = Issue.maximum('position_for_user',
          :include => :status,
          :conditions => ["#{IssueStatus.table_name}.is_closed = ? AND assigned_to_id = ? AND priority_id = ?", false, self.assigned_to_id, self.priority_id])
     if not max
       max = 0
     end
     return max + 1
  end

  def rebuild_position_for_user(user_id)

        issues = Issue.find(:all,
            :include => [:status, :priority],
            :conditions => ["#{IssueStatus.table_name}.is_closed = ? AND assigned_to_id = ?", false, user_id],
            :order => "#{IssuePriority.table_name}.position DESC, position_for_user, #{Issue.table_name}.id <> #{self.id}")

        i = 0
        issues.each do |issue|
            i = i + 1
            # if (issue.id != self.id) and (issue.position_for_user != i)
            if issue.position_for_user != i
              # logger.info "#{issue.id} -> #{i}, "
              # issue.update_attribute(:position_for_user, i)
              Issue.update_all({:position_for_user => i}, {:id => issue.id})
            end
        end

  end



  def apply_issue_close_date
   if self.status_id_changed? && self.status.try(:is_closed?)
    if self.due_date.nil? || self.due_date > Date.today
     puts "update due_date"
     self.due_date = Date.today
    end
   end
  end

  def assignable_versions_with_permission_edit
   vers = self.assignable_versions_without_permission_edit
   unless @now_in_validation
    if User.current
     unless User.current.allowed_to?(:edit_versions, nil, {:global => true})
     #unless User.current.allowed_to?(:edit_versions, self.project)
      vers = [self.fixed_version].compact
     end
    end
   end
   @assignable_versions = vers
  end

  def validate_with_permission_edit
   unless User.current.allowed_to?(:edit_versions, nil, {:global => true})
    if self.fixed_version_id_changed?
     self.errors.add :fixed_version_id, :denied
     self.fixed_version_id = self.fixed_version_id_was
    end
   end
   @now_in_validation = true
   self.validate_without_permission_edit
   @now_in_validation = false
  end

  def check_assigned_to_validity_in_status
   # для нового назначенного по workflow проверить возможность перехода в какое-либо состояние
   return true unless assigned_to
   return true unless status
   mmbership = assigned_to.memberships.select {|m| m.project_id == self.project.id}
   if mmbership.empty?
    rols = []
   else
    rols = mmbership.inject([]){|r, c| r + c.roles}
   end

   wfs = Workflow.find(:all,
                  :include => :new_status,
                  :conditions => {:role_id => rols.collect(&:id), :tracker_id => tracker.id}).compact.uniq
   errors.add(:assigned_to, "Задача не может быть назначена выбранному пользователю") unless wfs.select{|w| w.old_status.id == status.id }.size
   #logger.info "--- wf"
   #logger.info status.inspect
   #wfs.select{|w| w.old_status.id == status.id }.each do |w|
    #logger.info w.new_status.inspect
   #end
   #flds = assigned_to.groups.map(&:custom_field_values).flatten.compact.select{|v| v.custom_field.try(:name) == 'allowed_status' }
  end

 end
end

