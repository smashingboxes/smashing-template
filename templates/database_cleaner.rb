RSpec.configure do |config|
  config.use_transactional_fixtures = false
  
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do |example|
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, type: :feature) do
    unless Capybara.current_driver == :rack_test
      DatabaseCleaner.strategy = :truncation
    end
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end
end
