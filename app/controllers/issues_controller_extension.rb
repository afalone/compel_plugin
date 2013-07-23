module IssuesControllerExtension
 def self.included(base) # :nodoc:
  base.send(:include, InstanceMethods)
  base.class_eval do
   helper :repositories
   include RepositoriesHelper
  end
 end

 module InstanceMethods
 end
end


