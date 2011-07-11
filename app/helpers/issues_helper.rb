module IssuesHelper
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
     base.class_eval do
       alias_method_chain :sidebar_queries, :order
     end
   end
 
   module InstanceMethods
     def sidebar_queries_with_order
       queries = sidebar_queries_without_order
       queries.sort_by{|q| q.name }.sort_by{|q| Query.find(q.id).position || 999999 }
     end
   end
 end
