RSpec.configure do |config|
  config.after(:each, type: :controller) do
    SmashingDocs.run!(request, response, true)
  end
  # This is intentionally commented out. SmashingDocs will uncomment
  # it when running `rails g docs:build_docs`
  # config.after(:suite) { SmashingDocs.finish! }
  config.after(:suite) do
    examples = RSpec.world.filtered_examples.values.flatten
    after_hooks = [
      "bundle exec rubocop",
      "brakeman -q -w2 -z --no-summary",
      "bundle-audit --update"
    ]
    if examples.none?(&:exception) && ENV["DISABLE_POSTCHECKS"] != "true"
      after_hooks.each do |hook_command|
        system("echo ' ' && #{hook_command}")
        exitstatus = $?.exitstatus
        exit exitstatus if exitstatus.nonzero?
      end
    end
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.example_status_persistence_file_path = "spec/rspec_examples.txt"
  config.order = :random
  Kernel.srand config.seed
end
