Capybara.register_driver :chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new(
    args: %w[--no-sandbox --headless --disable-gpu --disable-dev-shm-usage]
  )
  Selenium::WebDriver::Chrome.driver_path = `which chromedriver`
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :headless_chrome # or optional :chrome for getting a browser locally
