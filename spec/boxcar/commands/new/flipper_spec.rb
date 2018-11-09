# frozen_string_literal: true

require "spec_helper"

RSpec.describe "boxcar new <app_name> --flipper" do
  context "when devise is installed" do
    before(:context) { setup_and_run_boxcar_new(["--flipper", "--devise"]) }

    it_behaves_like "a run that installs flipper"
    it_behaves_like "a run that includes all the basic setup steps"
    it_behaves_like "a run that installs a devise user model"

    it "installs routing constraints for the UI" do
      expect(File).to exist("#{project_path}/config/initializers/flipper_routing_constraints.rb")
    end
  end

  context "when devise is not installed" do
    before(:context) { setup_and_run_boxcar_new(["--flipper"]) }

    it_behaves_like "a run that installs flipper"
    it_behaves_like "a run that includes all the basic setup steps"

    it "does not install routing constraints for the UI" do
      expect(File).to_not exist(
        "#{project_path}/config/initializers/flipper_routing_constraints.rb"
      )
    end
  end
end
