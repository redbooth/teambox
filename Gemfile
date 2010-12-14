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
gem 'choices'
gem 'nokogiri'

group :plugins do
  gem 'thinking-sphinx', '~> 1.3.15', :require => nil
  gem 'will_paginate', '~> 2.3.14'
end

gem 'sprockets-rails', '~> 0.0.1'
gem 'vestal_versions', '~> 1.0.2'
gem 'paperclip', '~> 2.3.6'
gem 'teambox-permalink_fu', :require => 'permalink_fu'
gem 'cancan', '~> 1.2.0'

group :development do
  gem 'sqlite3-ruby', '~> 1.2.5', :require => nil
  gem 'ruby-debug', '~> 0.10.3', :require => nil
  gem 'mongrel', '~> 1.1.5', :require => nil
end

# we don't call the group :test because we don't want them auto-required
group :testing do
  gem 'database_cleaner', '~> 0.5.0'
  gem 'rspec-rails', '~> 1.3.3', :require => 'spec/rails'
  gem 'rcov'
  gem 'factory_girl', '~> 1.2.3'
  gem 'pickle', '~> 0.2.1'
  gem 'cucumber-rails', '~> 0.3.0', :require => nil
  gem 'capybara', '~> 0.3.5'
  gem 'launchy', '~> 0.3.5'
end
