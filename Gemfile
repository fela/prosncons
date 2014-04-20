source 'https://rubygems.org'

ruby "1.9.3"
gem 'rails', '3.2.13'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

#gem 'sqlite3', group: [:development, :test]
gem 'pg'#, group: :production
gem 'jquery-rails'
gem 'simple_form'
gem 'rdiscount'
gem 'cancan'
gem 'paper_trail', '~> 3.0.0'
# needed for Heroku
gem 'rails_12factor', group: :production


# Gems used only for assets and not required
# in production environments by default.
#group :assets do
  gem "therubyracer"
  gem "less-rails"
  gem 'twitter-bootstrap-rails'
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
  gem 'haml-rails'
#end

group :test do
  gem 'test-unit'
  gem 'mocha', :require => false
  gem 'timecop'
  gem 'capybara'
  #gem 'selenium-webdriver'
  gem 'selenium-webdriver', '~> 2.39.0'
  #gem 'capybara-webkit'
  #gem 'poltergeist'
  gem 'database_cleaner' # needed by capybara
  gem 'launchy'
end


#gem 'debugger', group: [:development, :test]

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'
