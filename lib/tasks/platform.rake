namespace :component do
  desc "Create all resources and components in local database"
  task :create => :environment do
    begin
      Platform::ResourceManager.create_all
      puts "#{BasicResource.count} resources and #{Component.count} components created!"
    rescue
      puts "An error has occurred while trying to create Components"
      puts "Please, verify the resource configuration file"
    end
  end

  desc "Register all resources and components in the Platform"
  task :register => :environment do
    begin
      Platform::ResourceManager.register_all
      puts "#{Component.where.not(uuid: nil).count} components registered!"
    rescue
      puts "An error has occurred while trying to register in the platform"
      puts "Please, verify the services configuration file"
    end
  end
end
