# The purpose of this class is to provide the building blocks that are used for generating a rails
# app. For example, the readme method is responsible for creating the readme file. Since we're
# inheriting from Rails::AppBuilder, we have a lot of those building blocks set up for us already.
# We can override those methods to customize how they work, or we can create new ones.
module Boxcar
  class AppBuilder < Rails::AppBuilder
    include Boxcar::Actions

    def gitignore
      copy_file "boxcar_gitignore", ".gitignore"
    end

    def readme
      template "README.md.erb", "README.md"
    end

    def configure_travis
      template "travis.yml.erb", ".travis.yml"
    end

    def gemfile
      config = {
        active_admin: options[:active_admin] || yes?("Install active admin? (y/N)"),
        tape: !options[:skip_tape]
      }
      template "Gemfile.erb", "Gemfile", config
    end

    def database_yml
      template "database.yml.erb", "config/database.yml"
    end

    def create_secrets_example
      run "cp config/secrets.yml config/secrets.example.yml"
    end

    def generate_rspec
      generate "rspec:install"
    end

    def configure_rspec
      remove_file "spec/rails_helper.rb"
      remove_file "spec/spec_helper.rb"
      copy_file "rails_helper.rb", "spec/rails_helper.rb"
      copy_file "spec_helper.rb", "spec/spec_helper.rb"
    end

    def create_database_cleaner_config
      copy_file "database_cleaner.rb", "spec/support/database_cleaner.rb"
    end

    def create_factory_bot_config
      copy_file "factory_bot.rb", "spec/support/factory_bot.rb"
    end

    def create_shoulda_matchers_config
      copy_file "shoulda_matchers.rb", "spec/support/shoulda_matchers.rb"
    end

    def install_tape
      run "tape installer install --no-vagrant"
      gsub_file "taperole/tape_vars.yml", /app_name:/, "app_name: #{app_name.underscore}"
    end

    # def install_active_admin
    #
    # end

    private

    # This is neccessary because the default `run` outputs in a different stream for some reason,
    # which was creating unwanted output in tests
    def run(command)
      say(super(command, capture: true))
    end

    # This is necessary because the default `generate` runs the default `run` instead of our run
    def generate(command)
      run "rails generate #{command}"
    end
  end
end
