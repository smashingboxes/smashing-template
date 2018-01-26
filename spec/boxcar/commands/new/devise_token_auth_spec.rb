require "spec_helper"

RSpec.describe "boxcar new <app_name> --api-only --devise-token-auth" do
  before(:all) { setup_and_run_boxcar_new(["--api-only", "--devise-token-auth"]) }

  it_behaves_like "a run that includes all the basic setup steps"

  it "installs devise_token_auth" do
    expect(gemfile).to match(/^gem "devise_token_auth"/)
    expect(File).to exist("#{project_path}/config/initializers/devise_token_auth.rb")
  end

  it_behaves_like "a run that installs a devise user model"
end
