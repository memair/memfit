source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

gem 'rails',        '~> 5.2.1'
gem 'pg',           '>= 0.18', '< 2.0'
gem 'puma',         '~> 3.11'
gem 'sass-rails',   '~> 5.0'
gem 'uglifier',     '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'turbolinks',   '~> 5'
gem 'jbuilder',     '~> 2.5'
gem 'bootsnap',     '>= 1.1.0', require: false

gem 'bootstrap',           '~> 4.1'
gem 'data-confirm-modal',  '1.6.2'
gem 'jquery-rails',        '~> 4.3'
gem 'jquery-ui-rails',     '~> 6.0'

gem 'devise',                 '~> 4.5'
gem 'omniauth-memair',        '0.0.3'
gem 'omniauth-google-oauth2', '0.5.3'

gem 'google-api-client', '~> 0.24', require: ['google/apis/fitness_v1']

gem 'memair', '~> 0.1.1'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'pry'
end

group :development do
  gem 'web-console',           '>= 3.3.0'
  gem 'listen',                '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'chromedriver-helper'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
