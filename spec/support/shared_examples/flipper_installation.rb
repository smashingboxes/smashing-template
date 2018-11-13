# frozen_string_literal: true

shared_examples_for "a run that installs flipper" do
  it "installs flipper" do
    expect(gemfile).to match(/^gem "flipper"/)
    expect(gemfile).to match(/^gem "flipper-ui"/)
    expect(gemfile).to match(/^gem "flipper-active_record"/)
    expect(File).to exist("#{project_path}/config/initializers/flipper.rb")
    expect(File).to exist("#{project_path}/config/initializers/flipper_ui.rb")
  end
end
