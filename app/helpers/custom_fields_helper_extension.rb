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
   unless v.custom_field.editor_id.nil? || User.current.roles_for_project(@project).map(&:id).include?(v.custom_field.editor_id)
    custom_field = v.custom_field
    field_name = "#{n}[custom_field_values][#{custom_field.id}]"
    field_id = "#{n}_custom_field_values_#{custom_field.id}"
    val = show_value(v)
    val = format_value(v.custom_field.default_value, v.custom_field.field_format) if val.blank? && v.custom_field.is_required?
    return custom_field_label_tag(n, v) + val + hidden_field_tag(field_name, val, :id => field_id)
   end
   return custom_field_tag_with_label_without_perm(n, v) if n != :issue || v.custom_field.name != "Источник ошибки"
   
   if User.current.allowed_to?(:compel_pos_source, nil, :global => true)
    custom_field_tag_with_label_without_perm(n, v)
   else
    ""
   end
  end
 end
end

