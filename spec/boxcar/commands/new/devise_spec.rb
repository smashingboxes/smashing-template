# frozen_string_literal: true

require "spec_helper"

RSpec.describe "boxcar new <app_name> --devise" do
  before(:all) { setup_and_run_boxcar_new(["--devise"]) }

  it_behaves_like "a run that includes all the basic setup steps"

  it "installs devise" do
    expect(gemfile).to match(/^gem "devise"/)
    expect(File).to exist("#{project_path}/config/initializers/devise.rb")
    expect(File).to exist("#{project_path}/config/locales/devise.en.yml")
  end

  it_behaves_like "a run that installs a devise user model"
end
