module CustomFieldsHelperExtension
 def self.included(base) # :nodoc:
  base.send(:include, InstanceMethods)
  base.class_eval do
   alias_method_chain :custom_field_tag_with_label, :perm
   alias_method_chain :custom_field_tag, :compel
  end
 end

 module InstanceMethods
 # Return custom field html tag corresponding to its format
  def custom_field_tag_with_compel(name, custom_value)
   custom_field = custom_value.custom_field
   field_name = "#{name}[custom_field_values][#{custom_field.id}]"
   field_id = "#{name}_custom_field_values_#{custom_field.id}"

   field_format = Redmine::CustomFieldFormat.find_by_name(custom_field.field_format)
   if %w(date text bool list).include?(field_format.edit_as)
    custom_field_tag_without_compel(name, custom_value)
   else
    text_field_tag(field_name, custom_value.value, :id => field_id, :maxlength => 150, :size => 80) # compel
   end
  end

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

