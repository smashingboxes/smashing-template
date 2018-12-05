Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new(
    args: %w[--no-sandbox --headless --disable-gpu --disable-dev-shm-usage]
  )
  Selenium::WebDriver::Chrome.driver_path = `which chromedriver`.chomp
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# Change this to :chrome to open a local browser
# driven_by option must also be changed to :chrome in spec_helper.rb
Capybara.javascript_driver = :headless_chrome
