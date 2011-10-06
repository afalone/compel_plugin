module IssueExtension
 def self.included(base)
  base.extend(IssueExtension::ClassMethods)
  base.send(:include, IssueExtension::InstanceMethods)
  base.class_eval do
   alias_method_chain :assignable_versions, :permission_edit
   alias_method_chain :validate, :permission_edit
  end
 end

 module ClassMethods

 end

 module InstanceMethods
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
 end
end

