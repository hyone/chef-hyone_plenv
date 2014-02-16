source 'https://rubygems.org'

gem 'chef', '~> 11.6.2'
gem 'berkshelf'

group :test do
 gem 'chefspec'
 gem 'foodcritic', '~> 3.0.3'
 gem 'tailor'
end

group :integration do
  gem 'test-kitchen'
  gem 'serverspec'
end

group :docker do
  gem 'kitchen-docker'
end

group :vagrant do
  gem 'kitchen-vagrant'
end

