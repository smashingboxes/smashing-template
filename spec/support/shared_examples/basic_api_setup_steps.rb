# frozen_string_literal: true

shared_examples_for "a run that includes all the basic API setup steps" do
  # Devise token auth is not compatible with Rails >= 5.2.0, we are temporarily
  # solving this by commenting out the test below until a patch is supported.
  # https://github.com/lynndylanhurley/devise_token_auth/issues/1079

  #  it_behaves_like "a run that includes all the basic setup steps"

  it "sets up the api controllers" do
    expect(File).to exist("#{project_path}/app/controllers/api/v1/api_controller.rb")
    expect(File).to exist("#{project_path}/app/controllers/api/v1/application_controller.rb")
  end
end
