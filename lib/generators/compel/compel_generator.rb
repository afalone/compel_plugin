class CompelGenerator < Rails::Generator::Base
  attr_reader   :controller_class_name,
                :class_name
  attr_accessor :attributes

def initialize(runtime_args, runtime_options = {})
    super
    #@name = runtime_args.first
    #@controller_class_name = @name.pluralize.capitalize
    @attributes = []

    runtime_args[0..-1].each do |arg|
      if arg.include? ':'
        @attributes << Rails::Generator::GeneratedAttribute.new(*arg.split(":"))
      end
    end
    puts "gen started"
  end

  def manifest
    #p record
    record do |m|
     m.template("initializer.rb", "config/initializers/compel_initializer.rb")
     #m.migration_template("migration_.rb", "db/migrate", :migration_file_name => "create_#{name.underscore.pluralize.camelize}")
      #m.template('controller.rb', "app/controllers/#{name.pluralize}_controller.rb")
      #m.template('model.rb', "app/models/#{name}.rb")
      #m.migration_template("migration.rb", "db/migrate", :migration_file_name => "create_#{name.underscore.pluralize.camelize}")

      #m.directory(File.join('app/views', name.pluralize))
      #for action in %w[ new edit show ]
      #  m.template(
      #    "view_#{action}.html.erb",
      #    File.join('app/views', controller_file_name, "#{action}.html.erb")
      #  )
      #end
    end
  end
end
