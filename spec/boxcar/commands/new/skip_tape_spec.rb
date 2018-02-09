require "spec_helper"

RSpec.describe "boxcar new <app_name> --skip-tape" do
  before(:all) { setup_and_run_boxcar_new(["--skip-tape"]) }

  it_behaves_like "a run that includes all the basic setup steps"

  it "does not include taperole in the Gemfile" do
    expect(gemfile).to_not match(/^gem "taperole"/)
  end

  it "does not set up tape" do
    expect(File).to_not exist("#{project_path}/taperole/hosts")
    expect(File).to_not exist("#{project_path}/taperole/tape_vars.yml")
    expect(File).to_not exist("#{project_path}/taperole/provision.yml")
    expect(File).to_not exist("#{project_path}/taperole/deploy.yml")
  end
end
