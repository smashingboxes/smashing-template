# frozen_string_literal: true

shared_examples_for "a run that installs pundit" do
  it "installs flipper" do
    expect(gemfile).to match(/^gem "pundit"/)
    expect(File).to exist("#{project_path}/app/policies/application_policy.rb")
    expect(File).to exist("#{project_path}/app/policies/user_policy.rb")
  end
end
