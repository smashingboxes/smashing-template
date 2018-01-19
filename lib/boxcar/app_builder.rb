# The purpose of this class is to provide the building blocks that are used for generating a rails
# app. For example, the readme method is responsible for creating the readme file. Since we're
# inheriting from Rails::AppBuilder, we have a lot of those building blocks set up for us already.
# We can override those methods to customize how they work, or we can create new ones.
module Boxcar
  class AppBuilder < Rails::AppBuilder
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
      template "Gemfile.erb", "Gemfile", gem_config
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

    def install_active_admin
      # NOTE: The --skip-comments won't work until this is merged:
      # https://github.com/activeadmin/activeadmin/issues/5322
      generate "active_admin:install --skip-users --skip-comments"
    end

    def gem_config
      # This is a class variable because the builder gets instantiated multiple times
      @@boxcar_gem_configs ||= { # rubocop:disable Style/ClassVars
        activeadmin: preference?(:active_admin, "Install active admin? (y/N)"),
        tape: !options[:skip_tape]
      }
    end

    def create_rubocop_config
      copy_file ".rubocop.yml", ".rubocop.yml"
    end

    def rubocop_autocorrect
      run "rubocop -a", capture: true
    end

    def cleanup_other_linter_violations
      remove_file "config/initializers/backtrace_silencers.rb"
      gsub_file "config/environments/production.rb", /^  # `config.assets.precompile`.*\n\n/, ""
      gsub_file "db/seeds.rb", /^\s*#.*\n/, ""
    end

    private

    # If a flag was given, return that. Otherwise, ask the user, with `yes?`
    def preference?(flag, question)
      options[flag].nil? ? yes?(question) : options[flag]
    end

    # This is neccessary because the default `run` outputs in a different stream for some reason,
    # which was creating unwanted output in tests
    def run(command, capture: false)
      output = super(command, capture: true)
      say(output) unless capture
      output
    end

    # This is necessary because the default `generate` runs the default `run` instead of our run
    def generate(command)
      run "rails generate #{command}"
    end
  end
end
