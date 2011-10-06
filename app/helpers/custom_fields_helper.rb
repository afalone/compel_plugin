module CustomFieldsHelper
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
     base.class_eval do
       alias_method_chain :custom_field_tag_with_label, :perm
     end
   end

   module InstanceMethods
     def custom_field_tag_with_label_with_perm(n, v)
       return custom_field_tag_with_label_without_perm(n, v) if n != :issue || v.custom_field.name != "Источник ошибки"
   
       if User.current.allowed_to?(:compel_pos_source, nil, :global => true)
        custom_field_tag_with_label_without_perm(n, v)
       else
        ""
       end
     end
   end
 end

