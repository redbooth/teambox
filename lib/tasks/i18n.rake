I18n.load_path = Dir[File.join(RAILS_ROOT, 'config/locales', '*.{rb,yml}')]

namespace :teambox do
  namespace :i18n do
    desc "render javascript for each locales"
    task :javascript do
      Dir.glob("#{RAILS_ROOT}/app/javascripts/i18n/*.erb").each  do |view| 
        write = "// render from #{view}\r"
        render = ERB.new File.new("#{RAILS_ROOT}/app/javascripts/i18n/timeago.erb").read
        puts "read #{File.basename(view)}"
        I18n.backend.available_locales.each do |locale|
          I18n.locale = locale
          write << "\r" << render.result
          puts "Render... " + locale.to_s
        end
        
        File.open("#{RAILS_ROOT}/app/javascripts/i18n/compiled/#{File.basename(view, '.erb')}.js", 'w+') {|f| f.write(write) }
        puts "write to #{File.basename(view, '.erb')}.js"
      end
      puts "You can now regenerate sprockets.js"
    end
  end
end