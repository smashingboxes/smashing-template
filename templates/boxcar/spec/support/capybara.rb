Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new(
    args: %w[--no-sandbox --headless --disable-gpu --disable-dev-shm-usage]
  )
  Selenium::WebDriver::Chrome.driver_path = `which chromedriver`.chomp
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# Change this to :chrome to open a local browser
Capybara.javascript_driver = :headless_chrome

# We need to override the default rspec-rails behavior to use our driver
RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    driven_by(:headless_chrome)
  end
end
