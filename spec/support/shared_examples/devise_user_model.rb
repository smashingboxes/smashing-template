# frozen_string_literal: true

shared_examples_for "a run that installs a devise user model" do
  it "sets up a User model" do
    user_model_path = "#{project_path}/app/models/user.rb"
    expect(File).to exist(user_model_path)

    user_model = IO.read(user_model_path)
    expect(user_model).to match(/^\s+devise.*$/)
  end
end
