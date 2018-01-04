require "spec_helper"

RSpec.describe "`boxcar new <app_name>`" do
  before(:all) do
    drop_dummy_database
    remove_project_directory
    run_boxcar_new
    setup_app_dependencies
  end

  it "uses custom Gemfile" do
    gemfile_file = IO.read("#{project_path}/Gemfile")
    expect(gemfile_file).to match(/^ruby "#{Boxcar::RUBY_VERSION}"$/)
    expect(gemfile_file).to match(/^gem "rails", "#{Boxcar::RAILS_VERSION}"$/)
  end

  it "uses custom Readme" do
    readme_file = IO.read("#{project_path}/README.md")
    expect(readme_file).to match(/^# #{BoxcarTestHelpers::APP_NAME.humanize}$/)
    expect(readme_file).to match(/^Ruby - #{Boxcar::RUBY_VERSION}$/)
    expect(readme_file).to match(/^Rails - #{Boxcar::RAILS_VERSION}$/)
  end

  it "configures travis" do
    travis_file = IO.read("#{project_path}/.travis.yml")
    expect(travis_file).to match(/^  - bundle exec rubocop$/)
    expect(travis_file).to match(/^  - bundle exec rspec$/)
  end

  it "sets up the database config" do
    database_yml = IO.read("#{project_path}/config/database.yml")
    expect(database_yml)
      .to match(/^  database: #{BoxcarTestHelpers::APP_NAME.underscore}_development$/)
  end

  it "sets up secrets.example.yml" do
    expect(File).to exist("#{project_path}/config/secrets.example.yml")
  end

  it "gitignores secrets.yml" do
    gitignore = IO.read("#{project_path}/.gitignore")
    expect(gitignore).to match(%r{^/config/secrets.yml$})
  end

  it "doesn't generate test directory" do
    expect(File).not_to exist("#{project_path}/test")
  end

  it "sets up rspec" do
    expect(File).to exist("#{project_path}/spec")
  end

  it "creates the database cleaner config" do
    expect(File).to exist("#{project_path}/spec/support/database_cleaner.rb")
  end

  it "creates the factory bot config" do
    expect(File).to exist("#{project_path}/spec/support/factory_bot.rb")
  end

  it "creates the shoulda matchers config" do
    expect(File).to exist("#{project_path}/spec/support/shoulda_matchers.rb")
  end
end
