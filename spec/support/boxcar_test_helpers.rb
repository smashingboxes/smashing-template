module BoxcarTestHelpers
  APP_NAME = "dummy_app".freeze

  def remove_project_directory
    FileUtils.rm_rf(project_path)
  end

  def create_tmp_directory
    FileUtils.mkdir_p(tmp_path)
  end

  def run_boxcar_new(arguments = nil)
    arguments = "--path=#{root_path} #{arguments}"
    Dir.chdir(tmp_path) do
      Bundler.with_clean_env do
        `
          #{boxcar_bin} new #{APP_NAME} #{arguments}
        `
      end
    end
  end

  def setup_app_dependencies
    if File.exist?(project_path)
      Dir.chdir(project_path) do
        Bundler.with_clean_env do
          `bundle check || bundle install`
        end
      end
    end
  end

  def drop_dummy_database
    if File.exist?(project_path)
      Dir.chdir(project_path) do
        Bundler.with_clean_env do
          `rails db:drop`
        end
      end
    end
  end

  def project_path
    @project_path ||= Pathname.new("#{tmp_path}/#{APP_NAME}")
  end

  def gemfile
    @gemfile ||= IO.read("#{project_path}/Gemfile")
  end

  private

  def tmp_path
    @tmp_path ||= Pathname.new("#{root_path}/tmp")
  end

  def boxcar_bin
    File.join(root_path, "bin", "boxcar")
  end

  def root_path
    File.expand_path("../../../", __FILE__)
  end

  def with_env(name, new_value)
    prior = ENV[name]
    ENV[name] = new_value.to_s

    yield
  ensure
    ENV[name] = prior
  end
end
