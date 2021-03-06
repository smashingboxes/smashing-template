# frozen_string_literal: true

module BoxcarTestHelpers
  APP_NAME = "dummy_app"

  attr_reader :output

  def remove_project_directory
    FileUtils.rm_rf(project_path)
  end

  def create_tmp_directory
    FileUtils.mkdir_p(tmp_path)
  end

  def run_boxcar_new(arguments = [])
    args = [APP_NAME] + arguments
    Dir.chdir(tmp_path) do
      before_gemfile = ENV["BUNDLE_GEMFILE"]
      ENV["BUNDLE_GEMFILE"] = gemfile_path
      Boxcar::Commands::New.start(args)
      ENV["BUNDLE_GEMFILE"] = before_gemfile
    end
  end

  def setup_app_dependencies
    return unless File.exist?(project_path)

    Dir.chdir(project_path) do
      Bundler.with_clean_env do
        `bundle check || bundle install`
      end
    end
  end

  def drop_dummy_database
    return unless File.exist?(project_path)

    Dir.chdir(project_path) do
      Bundler.with_clean_env do
        `rails db:drop`
      end
    end
  end

  def setup_and_run_boxcar_new(arguments = [])
    drop_dummy_database
    remove_project_directory
    reset_class_variables
    # This is here because we normally can't stub out methods in a `before(:all)`
    RSpec::Mocks.with_temporary_scope do
      allow(Thor::LineEditor).to receive(:readline).and_return("n")
      # Yield here, to allow for any additional stubbing
      yield if block_given?
      run_boxcar_new(arguments)
    end
  end

  # Expect the user to be prompted with the given question,
  # and return the given answer
  def expect_prompt_and_answer(question, answer)
    expect(Thor::LineEditor).to receive(:readline)
      .with("#{question} ", add_to_history: false)
      .and_return(answer)
  end

  # This resets class variables that are set for user preferences
  # Without these, user preferences would be persisted across our boxcar runs
  # (eg: when we test the --active-admin flag, it will think we already chose no)
  def reset_class_variables
    Boxcar::AppBuilder.class_variable_set :@@boxcar_configs, nil
  end

  def project_path
    @project_path ||= Pathname.new("#{tmp_path}/#{APP_NAME}")
  end

  def gemfile
    @gemfile ||= IO.read(gemfile_path)
  end

  def production_config
    @production_config ||= IO.read(production_config_path)
  end

  private

  def gemfile_path
    "#{project_path}/Gemfile"
  end

  def production_config_path
    "#{project_path}/config/environments/production.rb"
  end

  def tmp_path
    @tmp_path ||= Pathname.new("#{root_path}/tmp")
  end

  def boxcar_bin
    File.join(root_path, "bin", "boxcar")
  end

  def root_path
    File.expand_path("../../", __dir__)
  end
end

RSpec.configure do |config|
  config.include BoxcarTestHelpers
end
