module IssueExtension
 def self.included(base)
  base.extend(IssueExtension::ClassMethods)
  base.send(:include, IssueExtension::InstanceMethods)
  base.class_eval do
   after_save :reorder_positions
   before_save :store_work_dates
   before_save :init_position
   before_validation :apply_issue_close_date
   validate :check_assigned_to_validity_in_status
   protected :check_assigned_to_validity_in_status
   validate :validate_project_manager
   alias_method_chain :assignable_versions, :permission_edit
   #alias_method_chain :validate, :permission_edit
   alias_method_chain :validate_issue, :permission_edit
   alias_method_chain :due_before, :task_date
   safe_attributes 'due_task_date',
    :if => lambda {|issue, user| issue.new_record? || user.allowed_to?(:edit_issues, issue.project) }
   safe_attributes 'due_task_date',
    :if => lambda {|issue, user| issue.new_statuses_allowed_to(user).any? }
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
  def validate_project_manager
   if self.status_id_changed?
    if self.status_id_was == 1 and self.status_id == 7
     self.errors.add_to_base I18n.t(:need_project_manager) unless self.custom_values.detect{|v| v.custom_field.id == 22 && (!v.value.blank?)}
    end
   end
   # проверить статусы New -> проектирование
   # проверить наличие 
  end

  def due_before_with_task_date
    due_task_date || (fixed_version ? fixed_version.effective_date : nil)
  end

  def store_work_dates
   if self.status_id_changed? && self.due_task_date && !self.new_record?
    en = self.time_entries.new :hours => 0, :activity_id => 36, :spent_on => Date.today, :due_task_fact_date => Date.today, :due_task_date => self.due_task_date, :due_task_status_id => self.status_id_was
    en.user_id = (self.assigned_to_id_changed? ? self.assigned_to_id_was : self.assigned_to_id)
    en.save
    #TimeEntry.create(:project_id => self.project_id, :user_id => (self.assigned_to_id_changed? ? self.assigned_to_id_was : self.assigned_to_id), :issue_id => self.id, :due_task_date => self.due_task_date, :due_task_fact_date => Date.today, :due_task_status_id => self.status_id_was, :activity_id => 36, :hours => 0, :spent_on => Date.today)
   end
   if self.status_id_changed? && !self.new_record?
    if self.status_id == 4
     self.due_task_date = Date.today + 4 unless (self.due_task_date_changed? && !self.due_task_date.blank?)
    elsif self.status_id == 10
     self.due_task_date = Date.today + 1 unless (self.due_task_date_changed? && !self.due_task_date.blank?)
    elsif self.status_id == 13
     self.due_task_date = Date.today unless (self.due_task_date_changed? && !self.due_task_date.blank?)
    elsif self.status_id == 23
     self.due_task_date = Date.today + 7 unless (self.due_task_date_changed? && !self.due_task_date.blank?)
    elsif self.status_id == 35
     self.due_task_date = Date.today + 2 unless (self.due_task_date_changed? && !self.due_task_date.blank?)
    else
     self.due_task_date = nil unless (self.due_task_date_changed? && !self.due_task_date.blank?)
    end
   end
  end

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

  def validate_issue_with_permission_edit
   unless User.current.allowed_to?(:edit_versions, nil, {:global => true})
    if self.fixed_version_id_changed?
     self.errors.add :fixed_version_id, :denied
     self.fixed_version_id = self.fixed_version_id_was
    end
   end
   @now_in_validation = true

   if true
    if self.due_date.nil? && @attributes['due_date'] && !@attributes['due_date'].empty?
      errors.add :due_date, :not_a_date
    end

    if self.due_date and self.start_date and self.due_date < self.start_date
      errors.add :due_date, :greater_than_start_date
    end

    if start_date && soonest_start && start_date < soonest_start
      errors.add :start_date, :invalid
    end

    if fixed_version
      if !assignable_versions.include?(fixed_version)
        errors.add :fixed_version_id, :inclusion
      elsif reopened? && fixed_version.closed?
        errors.add_to_base I18n.t(:error_can_not_reopen_issue_on_closed_version)
      end
    end

    # Checks that the issue can not be added/moved to a disabled tracker
    if project && (tracker_id_changed? || project_id_changed?)
      unless project.trackers.include?(tracker)
        errors.add :tracker_id, :inclusion
      end
    end

    # Checks parent issue assignment
    if @parent_issue
      #if @parent_issue.project_id != project_id
      #  errors.add :parent_issue_id, :not_same_project
      #els
      if !new_record?
        # moving an existing issue
        if @parent_issue.root_id != root_id
          # we can always move to another tree
        elsif move_possible?(@parent_issue)
          # move accepted inside tree
        else
          errors.add :parent_issue_id, :not_a_valid_parent
        end
      end
    end

   else
    self.validate_issue_without_permission_edit
   end
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

