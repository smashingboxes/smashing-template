# frozen_string_literal: true

shared_examples_for "a run that installs capybara" do
  it "installs capybara" do
    expect(gemfile).to match(/^\s+gem "capybara"/)

    expect(File).to exist("#{project_path}/app/views/shared/home.html.erb")
    expect(File).to exist("#{project_path}/spec/system/home_page_spec.rb")
    expect(File).to exist("#{project_path}/spec/support/capybara.rb")
  end

  it "installs selenium-webdriver" do
    expect(gemfile).to match(/^\s+gem "selenium-webdriver"/)
  end
end
