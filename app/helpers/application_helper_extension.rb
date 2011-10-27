module ApplicationHelperExtension
 def self.included(base) # :nodoc:
  base.send(:include, InstanceMethods)
  base.class_eval do
   alias_method_chain :time_tag, :compel
  end
 end
 
 module InstanceMethods
  def time_tag_with_compel(time)
   text = format_time(time) # distance_of_time_in_words(Time.now, time)
   if @project
    link_to(text, {:controller => 'activities', :action => 'index', :id => @project, :from => time.to_date}, :title => format_time(time))
   else
    content_tag('acronym', text, :title => format_time(time))
   end
  end

 end
end
