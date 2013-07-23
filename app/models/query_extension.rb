module QueryExtension
 def self.included(base)
  base.extend(QueryExtension::ClassMethods)
  base.send(:include, QueryExtension::InstanceMethods)
  base.class_eval do
   self.available_columns << QueryColumn.new(:position_for_user, :sortable => "#{Issue.table_name}.position_for_user", :default_order => 'desc')
   self.available_columns << QueryColumn.new(:due_task_date, :sortable => "#{Issue.table_name}.due_task_date")
   alias_method_chain :available_filters, :compel
  end
 end

 module ClassMethods
 end

 module InstanceMethods
  def available_filters_with_compel
   unless @available_filters
    available_filters_without_compel
   end
   @available_filters.merge!( "position_for_user" =>  { :type => :integer,  :order => 16 }, "due_task_date" => { :type => :date, :order => 17 })
   available_filters_without_compel
 # compel todo
#                           "position_for_project" =>  { :type => :integer,  :order => 16 }, # compel todo
  end
 end
end

