require "spec_helper"

RSpec.describe "boxcar new <app_name> --active-admin" do
  before(:all) { setup_and_run_boxcar_new(["--active-admin"]) }

  it_behaves_like "a run that includes all the basic setup steps"

  it "includes activeadmin in the gemfile" do
    expect(gemfile).to match(/^gem "activeadmin"/)
  end

  it "installs activeadmin configs" do
    expect(File).to exist("#{project_path}/config/initializers/active_admin.rb")
  end
end
