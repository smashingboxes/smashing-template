require "rails_helper"

describe "Seeds" do
  context "Valid seeds" do
    before { Rails.application.class.parent_name.constantize::Application.load_tasks }

    it "does not raise errors" do
      expect { Rake::Task["db:seed"].invoke }.to_not raise_exception
    end
  end
end
