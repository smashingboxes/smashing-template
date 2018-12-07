# frozen_string_literal: true

shared_examples_for "a run that installs pundit" do
  it "installs pundit" do
    expect(gemfile).to match(/^gem "pundit"/)
    expect(File).to exist("#{project_path}/app/policies/application_policy.rb")
    expect(File).to exist("#{project_path}/app/policies/user_policy.rb")
    expect(File).to exist("#{project_path}/spec/policies/user_policy_spec.rb")
    expect(File).to exist("#{project_path}/spec/support/pundit.rb")
  end
end
