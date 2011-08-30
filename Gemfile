source :rubygems

gem 'rails', '~> 3.1.0.rc8'
gem 'memcache-client', '>= 1.7.4', :require => nil
#gem 'text-format', '>= 0.6.3', :require => 'text/format'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "  ~> 3.1.0.rc"
  gem 'coffee-rails', "~> 3.1.0.rc"
  gem 'uglifier'
end

gem 'json'
#gem 'coffee-script'
#gem 'jquery-rails'

#Temporary hack - Fix once this ticket: is resolved
gem 'activesupport-i18n-patch', :git => 'https://github.com/teambox/activesupport-i18n-patch.git'

gem 'nokogiri'
gem 'whenever', '~> 0.4.1', :require => nil
gem 'icalendar', '~> 1.1.3'
gem "libxml-ruby", "~> 1.1.4", :require => "libxml"
gem 'rdiscount', '~> 1.6.3'
gem 'haml', '~> 3.1.2'
gem 'mysql2', '~> 0.3.7'
gem 'pg', '~> 0.9.0', :require => nil, :group => 'pg'
gem 'aws-s3', '~> 0.6.2', :require => 'aws/s3'
gem 'hpricot', '~> 0.8.2'
gem 'json'
gem 'oa-oauth' #, '= 0.2.3', :require => 'omniauth/oauth'
gem 'hashie'
gem 'choices', :git => "https://github.com/teambox/choices.git"
gem 'rack-staticifier', :git => "https://github.com/remi/rack-staticifier.git"
gem 'rack-contrib', :require => 'rack/contrib'
gem 'trimmer', :git => "https://github.com/teambox/trimmer.git"
gem 'rabl'

gem "will_paginate", '~> 3.0.0'
gem 'thinking-sphinx', '2.0.5'
#gem 'vestal_versions', '~> 1.2.2', :git => 'https://github.com/adamcooper/vestal_versions.git'
gem 'paperclip', '~> 2.3.6'
gem 'teambox-permalink_fu', :require => 'permalink_fu'
gem 'cancan', '~> 1.4.1'
gem 'immortal', :git => "https://github.com/teambox/immortal.git"
#gem 'rack-ssl-enforcer', :require => 'rack/ssl-enforcer'
gem 'juggernaut'
gem 'sentient_user'
gem 'flash_cookie_session'
gem "redis", "~> 2.2.2"

group :development do
  #gem 'sqlite3-ruby', '~> 1.2.5', :require => nil
  #gem 'ruby-debug', '~> 0.10.3', :require => nil
  #gem 'mongrel', '~> 1.1.5', :require => nil
  #gem 'jasmine'
  gem "unicorn", '~> 4.1.0'
  gem 'foreman'
  gem 'haml-rails'
  gem 'active_reload'
  gem 'rspec-rails', '~> 2.6.0'
end

group :test do
  gem 'webrat'
  gem 'fuubar'
  gem 'faker', :require => nil
  gem 'timecop', :require => 'timecop'
  gem 'rspec-rails', '~> 2.6.0'
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

gem "rails_autolink", "~> 1.0.2"

##
# This should be the only difference between 1.8.7 and 1.9.2
#

gem 'SystemTimer', '~> 1.2.0', :require => 'system_timer'
