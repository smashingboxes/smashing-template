shared_examples_for "a run that includes all the basic setup steps" do
  it "returns a zero exit code" do
    expect(@failure).to_not eq(true)
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

  it "generates a project with no linter errors" do
    Dir.chdir(project_path) do
      Bundler.with_clean_env do
        `bundle exec rubocop`
        expect($?).to be_success
      end
    end
  end
end