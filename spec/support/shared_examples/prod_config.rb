# frozen_string_literal: true

shared_examples_for "a run that configures the production environment" do
  it "forces ssl" do
    expect(production_config).to match
  end
end