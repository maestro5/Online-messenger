source 'https://rubygems.org'
ruby '2.3.1'

gem 'sinatra', '~> 1.4', '>= 1.4.7'
gem 'activerecord', '~> 5.0', '>= 5.0.0.1'
gem 'sinatra-activerecord', '~> 2.0', '>= 2.0.10'
gem 'sinatra-flash', '~> 0.3.0'
gem 'rake', '~> 10.4', '>= 10.4.2'
gem 'aes', '~> 0.5.0'
gem 'slim', '~> 3.0', '>= 3.0.7'
gem 'rufus-scheduler', '~> 3.2', '>= 3.2.2'

group :development do
  gem 'sqlite3', '~> 1.3', '>= 1.3.11'
end

group :test, :development do
  gem 'rspec', '~> 3.5'
  gem 'capybara', '~> 2.9', '>= 2.9.1'
  gem 'factory_girl', '~> 4.7'
  gem 'database_cleaner', '~> 1.5', '>= 1.5.1'
end

group :test do
  gem 'rack-test', '~> 0.6.3'
  gem 'launchy', '~> 2.4', '>= 2.4.3'
end

group :production do
  gem 'pg', '~> 0.19.0'
end
