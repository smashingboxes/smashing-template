require "spec_helper"

RSpec.describe "boxcar new <app_name>" do
  before(:all) do
    setup_and_run_boxcar_new do
      # Prompt expectations go here because they're hard to test otherwise
      expect_prompt_and_answer("Is this an API only app? (y/N)", "n")
      expect_prompt_and_answer("Install Active Admin? (y/N)", "n")
      expect_prompt_and_answer("Install devise? (y/N)", "n")
    end
  end

  it_behaves_like "a run that includes all the basic setup steps"

  it "includes tape in the gemfile" do
    expect(gemfile).to match(/^gem "taperole"/)
  end

  it "installs tape" do
    expect(File).to exist("#{project_path}/taperole/hosts")

    tape_vars_path = "#{project_path}/taperole/tape_vars.yml"
    expect(File).to exist(tape_vars_path)

    tape_vars = IO.read(tape_vars_path)
    expect(tape_vars).to match(/^app_name: #{BoxcarTestHelpers::APP_NAME.underscore}$/)

    expect(File).to exist("#{project_path}/taperole/provision.yml")
    expect(File).to exist("#{project_path}/taperole/deploy.yml")
  end

  it "doesn't add activeadmin in the gemfile" do
    expect(gemfile).to_not match(/^gem "activeadmin"/)
  end

  it "doesn't add devise to the gemfile" do
    expect(gemfile).to_not match(/^gem "devise"/)
  end
end
