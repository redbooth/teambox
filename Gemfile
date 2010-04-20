source :gemcutter

group :rails do
  gem 'rails', '~> 2.3.5', :require => nil
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
gem 'libxml-ruby', '~> 1.1.3', :require => 'libxml'
gem 'rdiscount', '~> 1.6.3'
gem 'haml', '~> 3.0.0.beta1'
gem 'mysql', '~> 2.8.1'
gem 'aws-s3', '~> 0.6.2', :require => 'aws/s3'
gem 'hpricot', '~> 0.8.2'

group :plugins do
  gem 'sprockets-rails', '~> 0.0.1'
  gem 'acts-as-list', '~> 0.1.2', :require => 'acts_as_list'
  # gem 'acts_as_paranoid', '~> 0.3.1' # => too old!
  gem 'calendar_date_select', '~> 1.15'
  gem 'paperclip', '~> 2.3.1.1'
end

group :development do
  gem 'sqlite3-ruby', '~> 1.2.5', :require => nil
  gem 'ruby-debug', '~> 0.10.3', :require => nil
end

# we don't call the group :test because we don't want them auto-required
group :testing do
  gem 'database_cleaner', '~> 0.5.0'
  gem 'rspec-rails', '~> 1.3.2', :require => 'spec/rails'
  gem 'factory_girl', '~> 1.2.3'
  gem 'pickle', '~> 0.2.1'
  gem 'cucumber-rails', '~> 0.3.0', :require => nil
  gem 'capybara', '~> 0.3.5'
end
