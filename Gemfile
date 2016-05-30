source 'https://rubygems.org'

gemspec

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test do
  # Test the front end.
  gem 'minitest-rails-capybara'

  # Headless driver for Capybara.
  gem 'poltergeist'

  # Support 'save_and_open_screenshot' when debugging tests.
  gem 'launchy'

  # Opal unit testing.
  gem 'opal-minitest', github: 'dougo/opal-minitest'
end
