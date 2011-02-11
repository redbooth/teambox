source :rubygems

group :rails do
  gem 'rails', '~> 3.0.3'
  gem 'builder', '~> 2.1.2'
  gem 'memcache-client', '>= 1.7.4', :require => nil
  gem 'tzinfo', '~> 0.3.12'
  gem 'i18n', '>= 0.1.3'
  gem 'tmail', '~> 1.2.3'
  gem 'text-format', '>= 0.6.3', :require => 'text/format'
end

#Temporary hack - Fix once this ticket: is resolved
gem 'activesupport-i18n-patch', :git => 'git://github.com/teambox/activesupport-i18n-patch.git'

gem 'nokogiri'
gem 'SystemTimer', '~> 1.2.0', :require => 'system_timer'
gem 'whenever', '~> 0.4.1', :require => nil
gem 'icalendar', '~> 1.1.3'
gem 'libxml-ruby', '1.1.3', :require => 'libxml'
gem 'rdiscount', '~> 1.6.3'
gem 'haml', '~> 3.0.0.beta1'
# gem 'mysql2'
gem 'mysql', '~> 2.8.1', :require => nil, :group => 'mysql'
gem 'pg', '~> 0.9.0', :require => nil, :group => 'pg'
gem 'aws-s3', '~> 0.6.2', :require => 'aws/s3'
gem 'hpricot', '~> 0.8.2'
gem 'json'
gem 'oa-oauth', :require => 'omniauth/oauth'
gem 'tilt'
gem 'choices', :git => "git://github.com/teambox/choices.git"

gem "will_paginate", :git=>"git://github.com/mislav/will_paginate.git", :branch=>"rails3"
gem 'thinking-sphinx', '2.0.1', :require => 'thinking_sphinx'
gem 'sprockets-rails', '~> 0.0.1'
gem 'barista', '~> 1.0'
gem 'vestal_versions', '~> 1.2.2', :git => 'git://github.com/adamcooper/vestal_versions'
gem 'paperclip', '~> 2.3.6'
gem 'teambox-permalink_fu', :require => 'permalink_fu'
gem 'cancan', '~> 1.4.1'
gem 'immortal'
gem 'rack-ssl-enforcer', :require => 'rack/ssl-enforcer' 
gem 'jammit'

group :development do
  gem 'sqlite3-ruby', '~> 1.2.5', :require => nil
  gem 'ruby-debug', '~> 0.10.3', :require => nil
  gem 'mongrel', '~> 1.1.5', :require => nil
end

group :test, :development do
  gem 'rspec-rails', '~> 2.3.1'
  gem 'webrat'
  gem 'fuubar'
  gem 'faker', :require => nil
end

# we don't call the group :test because we don't want them auto-required
group :testing do
  gem 'database_cleaner', '~> 0.5.0'
  gem 'rcov'
  gem 'factory_girl', '~> 1.3.2'
  gem 'pickle', '~> 0.4.4'
  gem 'cucumber-rails', '~> 0.3.2', :require => nil
  gem 'capybara', '~> 0.4.0'
  gem 'launchy', '~> 0.3.7'
end
