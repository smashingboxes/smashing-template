require "spec_helper"

RSpec.describe "Create a new app with default configuration" do
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

  pending "configures travis"
  pending "configures the database"
  pending "creates the local database"
end
