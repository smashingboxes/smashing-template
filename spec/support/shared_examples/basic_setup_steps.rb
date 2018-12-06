# frozen_string_literal: true

DEFAULT_GEMS = %w[annotate
                  awesome_print
                  brakeman
                  bundler-audit
                  database_cleaner
                  faker
                  pry-byebug
                  rails-erd
                  rspec-rails
                  rubocop
                  shoulda-matchers
                  simplecov].freeze

shared_examples_for "a run that includes all the basic setup steps" do
  it "uses custom Gemfile" do
    expect(gemfile).to match(/^ruby "#{Boxcar::RUBY_VERSION}"$/)
    expect(gemfile).to match(/^gem "rails", "#{Boxcar::RAILS_VERSION}"$/)
  end

  it "uses custom Readme" do
    readme_file = IO.read("#{project_path}/README.md")
    expect(readme_file).to match(/^# #{BoxcarTestHelpers::APP_NAME.humanize}$/)
    expect(readme_file).to match(/^- Ruby - #{Boxcar::RUBY_VERSION}$/)
    expect(readme_file).to match(/^- Rails - #{Boxcar::RAILS_VERSION}$/)
  end

  it "configures travis" do
    travis_file = IO.read("#{project_path}/.travis.yml")
    expect(travis_file).to match(/^  - bundle exec rubocop$/)
    expect(travis_file).to match(/^  - bundle exec rspec$/)
  end

  it "creates a .ruby-version file" do
    expect(File).to exist("#{project_path}/.ruby-version")
  end

  it "sets up a Procfile" do
    procfile_path = "#{project_path}/Procfile"
    expect(File).to exist(procfile_path)
    procfile = IO.read(procfile_path)
    expect(procfile).to match(/^backend: bundle exec rails server -p 3000$/)
  end

  it "sets up the database config" do
    database_yml = IO.read("#{project_path}/config/database.yml")
    expect(database_yml)
      .to match(/^  database: #{BoxcarTestHelpers::APP_NAME.underscore}_development$/)
  end

  it "sets up secrets.yml" do
    secrets_path = "#{project_path}/config/secrets.yml"
    expect(File).to exist(secrets_path)
    secrets_file = IO.read(secrets_path)
    expect(secrets_file).to match(/^shared:/)
  end

  it "creates the query traces file" do
    expect(File).to exist("#{project_path}/config/initializers/query_trace.rb")
  end

  it "sets up .env.example and copies it to .env" do
    expect(File).to exist("#{project_path}/.env.example")
    expect(File).to exist("#{project_path}/.env")
  end

  it "gitignores .env" do
    gitignore = IO.read("#{project_path}/.gitignore")
    expect(gitignore).to match(/^.env$/)
  end

  it "sets up .erdconfig file" do
    expect(File).to exist("#{project_path}/.erdconfig")
  end

  it "sets up pull_request_template.md" do
    expect(File).to exist("#{project_path}/.github/pull_request_template.md")
  end

  it "includes all of the defaults gems" do
    DEFAULT_GEMS.each do |gem|
      expect(gemfile).to match(/gem "#{gem}"/)
    end
  end

  it "adds the annotate rake task" do
    expect(File).to exist("#{project_path}/lib/tasks/auto_annotate_models.rake")
  end

  it "generates a template seeds.rb" do
    seeds_path = "#{project_path}/db/seeds.rb"
    expect(File).to exist(seeds_path)
    seeds_file = IO.read(seeds_path)
    expect(seeds_file)
      .to include("Dir[File.dirname(__FILE__) + \"/seeds/*.rb\"].each { |file| require file }")
  end

  it "generates an example seed class" do
    expect(File).to exist("#{project_path}/db/seeds/user_seeds.rb")
  end

  it "doesn't generate test directory" do
    expect(File).to_not exist("#{project_path}/test")
  end

  it "sets up rspec" do
    expect(File).to exist("#{project_path}/spec")
  end

  it "creates rails_helper.rb" do
    rails_helper_path = "#{project_path}/spec/rails_helper.rb"
    expect(File).to exist(rails_helper_path)
    rails_helper = IO.read(rails_helper_path)
    expect(rails_helper)
      .to match(%r{^Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }$})
  end

  it "creates spec_helper.rb" do
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

  it "creates the request helpers config" do
    expect(File).to exist("#{project_path}/spec/support/request_helpers.rb")
  end

  it "includes the seeds_spec test" do
    expect(File).to exist("#{project_path}/spec/seeds/seed_spec.rb")
  end

  it "generates a project with no linter errors" do
    Dir.chdir(project_path) do
      Bundler.with_clean_env do
        output = `bundle exec rubocop`
        puts output unless $CHILD_STATUS.success?
        expect($CHILD_STATUS).to be_success
      end
    end
  end

  it_behaves_like "a run that installs pundit"

  it_behaves_like "a run that installs capybara"

  it_behaves_like "a run that configures the prod environment"

  it "generated a project with all passing specs" do
    Dir.chdir(project_path) do
      Bundler.with_clean_env do
        output = `bundle exec rspec`
        puts output unless $CHILD_STATUS.success?
        expect($CHILD_STATUS).to be_success
      end
    end
  end
end
