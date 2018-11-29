# frozen_string_literal: true

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

  it "adds the frontend to the procfile" do
    procfile = IO.read("#{project_path}/Procfile")
    expect(procfile).to match(%r{frontend: bin/webpack-dev-server$})
  end

  describe "frontend linting" do
    it "adds our eslint config" do
      expect(File).to exist("#{project_path}/.eslintrc")
    end

    it "adds our stylelint config" do
      expect(File).to exist("#{project_path}/stylelint.config.js")
    end

    it "adds package.json scripts for eslint and stylelint" do
      package_json = IO.read("#{project_path}/package.json")
      expect(package_json).to include('"lint": "npm run lint:css && npm run lint:js"')
      expect(package_json).to include("lint:css")
      expect(package_json).to include("lint:js")
    end

    it "doesn't have any eslint violations" do
      Dir.chdir(project_path) do
        Bundler.with_clean_env do
          `yarn install && yarn lint`
          expect($CHILD_STATUS).to be_success
        end
      end
    end

    it "configures travis to run eslint" do
      expect(IO.read("#{project_path}/.travis.yml")).to match(/^  - yarn lint$/)
    end
  end

  describe "ActionMailer configs" do
    it "adds letter_opener to the gemfile" do
      expect(gemfile).to match(/^\s+gem "letter_opener"/)
    end

    it "configures the development environment to use letter_opener" do
      development = IO.read("#{project_path}/config/environments/development.rb")
      expect(development).to match(/^\s*config.action_mailer.delivery_method = :letter_opener$/)
      expect(development).to match(/^\s*config.action_mailer.perform_deliveries = true$/)
      expect(development).to match(/^\s*config.action_mailer.default_url_options.*$/)
    end

    it "adds mailgun-ruby to the gemfile" do
      expect(gemfile).to match(/^gem "mailgun-ruby"/)
    end

    it "configures the production environment to use mailgun" do
      production = IO.read("#{project_path}/config/environments/production.rb")
      expect(production).to match(/^\s*config.action_mailer.default_url_options.*$/)
      expect(production).to match(/^\s*config.action_mailer.delivery_method = :mailgun$/)
      expect(production).to match(/^\s*config.action_mailer.mailgun_settings = {$/)
    end

    it "adds the mailgun lines to secrets.yml" do
      secrets = IO.read("#{project_path}/config/secrets.yml")
      expect(secrets).to match(/^\s*mailgun_api_key: <%= ENV\["MAILGUN_API_KEY"\] %>$/)
      expect(secrets).to match(/^\s*mailgun_domain: <%= ENV\["MAILGUN_DOMAIN"\] %>$/)
    end
  end
end
