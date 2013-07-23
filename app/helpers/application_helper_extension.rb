module ApplicationHelperExtension
 def self.included(base) # :nodoc:
  base.send(:include, InstanceMethods)
  base.class_eval do
   alias_method_chain :time_tag, :compel
   alias_method_chain :page_header_title, :compel
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

  def page_header_title_with_compel
   pre = page_header_title_without_compel
   unless @project.nil? || @project.new_record?
    s1 = pre #.join(' &#187; ')
    if params[:project_id]
     options = { }
     options[:project_id] = nil
     options[:query_id] = params[:query_id]
     s2 = link_to('&nbsp;&laquo;&nbsp;', options, {:title => l(:button_back)})
    else
     s2 = link_to_function('&nbsp;&laquo;&nbsp;', 'history.back()', {:title => l(:button_back)})
    end
    return s2 + s1
   end
   pre
  end
 end
end
