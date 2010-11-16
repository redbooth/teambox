def teambox_data_import(make_data)
  if ENV['TEAMBOX_DATA']
    #begin
      object_maps = {
        'User' => {},
        'Organization' => {}
      }
      (ENV['TEAMBOX_USERS']||'').strip.split(',').each do |entry|
        entry.split('=').tap {|values| object_maps['User'][values[0]] = values[1] }
      end
      TeamboxData.import_from_file(ENV['TEAMBOX_DATA'], object_maps, {:create_users => make_data, 
                                                                      :create_organizations => make_data,
                                                                      :format => ENV['TEAMBOX_DATA_FORMAT']})
    #rescue Exception => e
    #  puts e
    #end
  else
    puts "Please specify your teambox dump via TEAMBOX_DATA"
  end
end

namespace :data do
  desc "Export data"
  task :export => :environment do
    begin
      TeamboxData.export_to_file(Project.all, User.all, Organization.all, "export-#{Time.now.to_s}.json")
    rescue Exception => e
      puts e
    end
  end
  
  desc "Import data"
  task :import => :environment do
    teambox_data_import(false)
  end
  
  desc "Import data, including users and organizations"
  task :import_new => :environment do
    teambox_data_import(true)
  end
end

