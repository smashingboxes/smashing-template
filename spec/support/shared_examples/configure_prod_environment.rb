# frozen_string_literal: true

shared_examples_for "a run that configures the prod environment" do
  it "forces ssl configuration" do
    expect(production_config).to match(/^\s+config.force_ssl = true/)
  end
end
