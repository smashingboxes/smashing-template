require "spec_helper"

RSpec.describe Boxcar::Commands::New do
  before(:each) { Boxcar::AppBuilder.class_variable_set :@@boxcar_gem_configs, nil }

  context "with no arguments" do
    before(:all) do
      setup_and_run_boxcar_new do
        # it "asks whether to install active_admin"
        expect(Thor::LineEditor).to receive(:readline)
          .with("Install active admin? (y/N) ", add_to_history: false).and_return("n")
      end
    end

    it "uses custom Gemfile" do
      expect(gemfile).to match(/^ruby "#{Boxcar::RUBY_VERSION}"$/)
      expect(gemfile).to match(/^gem "rails", "#{Boxcar::RAILS_VERSION}"$/)
    end

    it "uses custom Readme" do
      readme_file = IO.read("#{project_path}/README.md")
      expect(readme_file).to match(/^# #{BoxcarTestHelpers::APP_NAME.humanize}$/)
      expect(readme_file).to match(/^Ruby - #{Boxcar::RUBY_VERSION}$/)
      expect(readme_file).to match(/^Rails - #{Boxcar::RAILS_VERSION}$/)
    end

    it "configures travis" do
      travis_file = IO.read("#{project_path}/.travis.yml")
      expect(travis_file).to match(/^  - bundle exec rubocop$/)
      expect(travis_file).to match(/^  - bundle exec rspec$/)
    end

    it "sets up the database config" do
      database_yml = IO.read("#{project_path}/config/database.yml")
      expect(database_yml)
        .to match(/^  database: #{BoxcarTestHelpers::APP_NAME.underscore}_development$/)
    end

    it "sets up secrets.example.yml" do
      expect(File).to exist("#{project_path}/config/secrets.example.yml")
    end

    it "gitignores secrets.yml" do
      gitignore = IO.read("#{project_path}/.gitignore")
      expect(gitignore).to match(%r{^/config/secrets.yml$})
    end

    it "doesn't generate test directory" do
      expect(File).not_to exist("#{project_path}/test")
    end

    it "sets up rspec" do
      expect(File).to exist("#{project_path}/spec")
    end

    it "configures rspec" do
      rails_helper_path = "#{project_path}/spec/rails_helper.rb"
      expect(File).to exist(rails_helper_path)
      rails_helper = IO.read(rails_helper_path)
      expect(rails_helper)
        .to match(%r{^Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }$})

      spec_helper_path = "#{project_path}/spec/spec_helper.rb"
      expect(File).to exist(spec_helper_path)

      spec_helper = IO.read(spec_helper_path)
      expect(spec_helper).to match(/^\s+"bundle exec rubocop",$/)
      expect(spec_helper).to match(/^\s+"brakeman -q -w2 -z --no-summary",$/)
      expect(spec_helper).to match(/^\s+"bundle-audit --update"$/)
    end

    it "creates the database cleaner config" do
      expect(File).to exist("#{project_path}/spec/support/database_cleaner.rb")
    end

    it "creates the factory bot config" do
      expect(File).to exist("#{project_path}/spec/support/factory_bot.rb")
    end

    it "creates the shoulda matchers config" do
      expect(File).to exist("#{project_path}/spec/support/shoulda_matchers.rb")
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

    # pending "installs devise/devise_token_auth"
    # pending "installs smashing_docs"

    it "generates a project with no linter errors" do
      Dir.chdir(project_path) do
        Bundler.with_clean_env do
          `bundle exec rubocop`
          expect($?).to be_success
        end
      end
    end
  end

  context "when given the skip-tape flag" do
    before(:all) { setup_and_run_boxcar_new(["--skip-tape"]) }

    it "does not include taperole in the Gemfile" do
      expect(gemfile).to_not match(/gem "taperole"/)
    end

    it "does not set up tape" do
      expect(File).to_not exist("#{project_path}/taperole/hosts")
      expect(File).to_not exist("#{project_path}/taperole/tape_vars.yml")
      expect(File).to_not exist("#{project_path}/taperole/provision.yml")
      expect(File).to_not exist("#{project_path}/taperole/deploy.yml")
    end
  end

  context "When given the active-admin flag" do
    before(:all) { setup_and_run_boxcar_new(["--active-admin"]) }

    it "installs active_admin" do
      expect(gemfile).to match(/^gem "activeadmin".*/)
    end
  end
end
