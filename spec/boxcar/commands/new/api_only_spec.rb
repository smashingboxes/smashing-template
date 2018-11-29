# frozen_string_literal: true

require "spec_helper"

RSpec.describe "boxcar new <app_name> --api-only" do
  before(:all) { setup_and_run_boxcar_new(["--api-only"]) }

  it_behaves_like "a run that includes all the basic API setup steps"
end
