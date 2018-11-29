# frozen_string_literal: true

require "spec_helper"

RSpec.describe "boxcar new <app_name> --api-only --devise-token-auth" do
  before(:all) { setup_and_run_boxcar_new(["--api-only", "--devise-token-auth"]) }

  it_behaves_like "a run that includes all the basic API setup steps"

  it "installs devise_token_auth" do
    expect(gemfile).to match(/^gem "devise_token_auth"/)
    expect(File).to exist("#{project_path}/config/initializers/devise_token_auth.rb")
  end

  it "sets up the auth helpers" do
    expect(File).to exist("#{project_path}/spec/requests/api/v1/users/sign_in_spec.rb")
  end

  it "sets up the spec helpers" do
    expect(File).to exist("#{project_path}/spec/support/requests.rb")
  end

  it "sets up the render helpers" do
    expect(File).to exist("#{project_path}/app/controllers/concerns/render_helper.rb")
  end

  it "sets up the devise controllers" do
    expect(File)
      .to exist("#{project_path}/app/controllers/concerns/devise_token_auth_response_serializer.rb")
    expect(File).to exist("#{project_path}/app/controllers/api/v1/users/registration_controller.rb")
    expect(File).to exist("#{project_path}/app/controllers/api/v1/users/sessions_controller.rb")
  end

  it_behaves_like "a run that installs a devise user model"
end
