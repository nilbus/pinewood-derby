source 'https://rubygems.org'

gem 'rails', '~> 4.1.0.beta1'
gem 'thin-rails'
gem 'sqlite3'
gem 'daemons-rails'
gem 'faye-rails', github: 'nilbus/faye-rails', branch: 'rails4'
gem 'faye-redis'
gem 'foreman'
gem 'serialport'
gem 'iobuffer'
gem 'bootstrap-sass', '~> 2.2.1.1'

group :development do
  gem 'pry-rails'
  gem 'pry-debugger'
  gem 'faker'
end

group :test, :development do
  gem 'database_cleaner'
  gem 'guard-rspec', github: 'guard/guard-rspec', ref: '394596b647d7082c0487bf5c11e36702ccbf5bf1'
  gem 'rspec-rails', '~> 3.0.0.beta1'
  gem 'spring-commands-rspec'
  gem 'teaspoon'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sprockets-rails'
  gem 'sass-rails'
  gem 'coffee-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', platforms: :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder'

# Deploy with Capistrano
# gem 'capistrano', group: :development

# To use debugger
# gem 'debugger'
