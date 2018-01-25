require "spec_helper"

# TODO: Refactor this file into a few smaller files
RSpec.describe Boxcar::Commands::New do
  context "with no arguments" do
    before(:all) do
      setup_and_run_boxcar_new do
        # Prompt expectations go here because they're hard to test otherwise
        expect_prompt_and_answer("Is this an API only app? (y/N)", "n")
        expect_prompt_and_answer("Install active admin? (y/N)", "n")
        expect_prompt_and_answer("Install devise? (y/N)", "n")
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
      expect(gemfile).to_not match(/^gem "taperole"/)
    end

    it "does not set up tape" do
      expect(File).to_not exist("#{project_path}/taperole/hosts")
      expect(File).to_not exist("#{project_path}/taperole/tape_vars.yml")
      expect(File).to_not exist("#{project_path}/taperole/provision.yml")
      expect(File).to_not exist("#{project_path}/taperole/deploy.yml")
    end
  end

  context "when given the active-admin flag" do
    before(:all) { setup_and_run_boxcar_new(["--active-admin"]) }

    it "includes activeadmin in the gemfile" do
      expect(gemfile).to match(/^gem "activeadmin"/)
    end

    it "installs activeadmin configs" do
      expect(File).to exist("#{project_path}/config/initializers/active_admin.rb")
    end
  end

  shared_examples_for "a run that installs a devise user model" do
    it "sets up a User model" do
      user_model_path = "#{project_path}/app/models/user.rb"
      expect(File).to exist(user_model_path)

      user_model = IO.read(user_model_path)
      expect(user_model).to match(/^\s+devise.*$/)
    end
  end

  context "When given the devise flag" do
    before(:all) { setup_and_run_boxcar_new(["--devise"]) }

    it "installs devise" do
      expect(gemfile).to match(/^gem "devise"/)
      expect(File).to exist("#{project_path}/config/initializers/devise.rb")
      expect(File).to exist("#{project_path}/config/locales/devise.en.yml")
    end

    it_behaves_like "a run that installs a devise user model"
  end

  context "when generating an API-only app" do
    before(:all) do
      setup_and_run_boxcar_new(["--api-only"]) do
        expect_prompt_and_answer("Install devise_token_auth? (y/N)", "n")
      end
    end

    it "doesn't install devise_token_auth" do
      expect(gemfile).to_not match(/^gem "devise_token_auth"/)
    end
  end

  context "when generating an API-only app with devise_token_auth" do
    before(:all) { setup_and_run_boxcar_new(["--api-only", "--devise-token-auth"]) }

    it "installs devise_token_auth" do
      expect(gemfile).to match(/^gem "devise_token_auth"/)
      expect(File).to exist("#{project_path}/config/initializers/devise_token_auth.rb")
    end

    it_behaves_like "a run that installs a devise user model"
  end
end
