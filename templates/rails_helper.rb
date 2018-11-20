# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require "selenium/webdriver"
require "spec_helper"
require "support/request_helpers"

ENV["RAILS_ENV"] ||= "test"

require File.expand_path("../config/environment", __dir__)

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"

# Add additional requires below this line. Rails is not loaded until this point!

# Requires all support files
Dir[Rails.root.join("spec", "support", "**", "*.rb")].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

Capybara.register_driver :chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new(
    args: %w[--no-sandbox --headless --disable-gpu --disable-dev-shm-usage]
  )
  Selenium::WebDriver::Chrome.driver_path = `which chromedriver`
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :headless_chrome # or optional :chrome for getting a browser locally

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
