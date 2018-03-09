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
      template "Gemfile.erb", "Gemfile", gem_configs
    end

    def database_yml
      template "database.yml.erb", "config/database.yml"
    end

    def create_secrets_example
      run "cp config/secrets.yml config/secrets.example.yml"
    end

    def generate_rspec
      generate "rspec:install"
      install_specs
    end

    def install_specs
      copy_file "seed_spec.rb", "spec/seeds/seed_spec.rb"
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

    def create_request_helpers_config
      copy_file "request_helpers.rb", "spec/support/request_helpers.rb"
    end

    def install_tape
      run "tape installer install --no-vagrant"
      gsub_file "taperole/tape_vars.yml", /app_name:/, "app_name: #{app_name.underscore}"
    end

    def install_activeadmin
      generate "active_admin:install --skip-users --skip-comments"
      split_long_comments "config/initializers/active_admin.rb"
      gsub_file "app/admin/dashboard.rb", "end # content", "end"
    end

    def install_devise
      generate "devise:install"
      generate "devise User"
      gsub_file "config/initializers/devise.rb", /# config.secret_key.*/, "# config.secret_key = ''"
      gsub_file "config/initializers/devise.rb", /# config.pepper.*/, "# config.pepper = ''"
    end

    def install_devise_token_auth
      generate "devise_token_auth:install User auth"
      # This does two things different from the default.
      # 1. It inherits from ApplicationRecord instead of ActiveRecord::Base
      # 2. It doesn't include omniauthable by default
      copy_file "user.rb", "app/model/user.rb"
      copy_file "users_factory.rb", "spec/factories/users_factory.rb"
    end

    def create_routes
      remove_file "config/routes.rb"
      template "routes.rb.erb", "config/routes.rb", gem_configs
    end

    def create_github_markdown
      copy_file "pull_request_template.md", ".github/pull_request_template.md"
    end

    def create_devise_token_auth_helpers
      api_controller
      devise_controller
      render_helper
      spec_request_helper
      spec_auth_helpers
      auth_specs
    end

    def auth_specs
      copy_file "sign_in_spec.rb", "spec/requests/api/v1/users/sign_in_spec.rb"
    end

    def spec_auth_helpers
      copy_file "auth_helper.rb", "spec/support/auth_helper.rb"
      copy_file "valid_sign_in_credentials.rb", "spec/support/valid_sign_in_credentials.rb"
      copy_file "valid_sign_in.rb", "spec/support/valid_sign_in.rb"
    end

    def spec_request_helper
      copy_file "requests.rb", "spec/support/requests.rb"
    end

    def render_helper
      copy_file "render_helper.rb", "app/controllers/concerns/render_helper.rb"
    end

    def devise_controller
      copy_file "devise_token_auth_response_serializer.rb",
                "app/controllers/concerns/devise_token_auth_response_serializer.rb"
      copy_file "registrations_controller.rb",
                "app/controllers/api/v1/users/registration_controller.rb"
      copy_file "sessions_controller.rb", "app/controllers/api/v1/users/sessions_controller.rb"
    end

    def api_controller
      copy_file "api_controller.rb", "app/controllers/api/v1/api_controller.rb"
      copy_file "application_controller.rb", "app/controllers/api/v1/application_controller.rb"
    end

    def setup_database
      run "rails db:create"
    end

    def migrate_database
      run "rails db:migrate"
    end

    def setup_annotate
      copy_file "auto_annotate_models.rake", "lib/tasks/auto_annotate_models.rake"
    end

    def create_rubocop_config
      copy_file ".rubocop.yml", ".rubocop.yml"
    end

    def rubocop_autocorrect
      run "rubocop -a", capture: true
    end

    def cleanup_other_linter_violations
      split_long_comments "config/initializers/backtrace_silencers.rb"
      split_long_comments "config/environments/production.rb"
      split_long_comments "db/seeds.rb"
    end

    # rubocop:disable Style/ClassVars
    # These are stored in class variables because the builder gets instantiated multiple times,
    # and we want to remember those preferences across instantiations
    def boxcar_configs
      @@boxcar_configs ||= begin
        api_app = preference?(:api_only, "Is this an API only app? (y/N)")
        gems = {}
        if api_app
          gems[:devise] = false
          gems[:devise_token_auth] =
            preference?(:devise_token_auth, "Install devise_token_auth? (y/N)")
          gems[:active_model_serializers] = true
        else
          gems[:devise] = preference?(:devise, "Install devise? (y/N)")
          gems[:devise_token_auth] = false
        end
        gems[:activeadmin] = preference?(:activeadmin, "Install Active Admin? (y/N)")
        gems[:tape] = !options[:skip_tape]

        {
          api_app: api_app,
          gems: gems
        }
      end
    end
    # rubocop:enable Style/ClassVars

    def gem_configs
      boxcar_configs[:gems]
    end

    private

    def split_long_comments(filename)
      gsub_file filename, /(.){100,}/ do |match|
        split_long_comment_string(match)
      end
    end

    def split_long_comment_string(line)
      limit = 100

      # Find any comment lines, and capture the start of the line
      matches = line.match(/(\A\s*\#)[^{]/)
      return line unless matches
      # This will be the "  #" part. There might be multiple spaces before the pound symbol.
      line_prefix = matches[0]
      comment_limit = limit - line_prefix.length

      # Take all content after the pound symbol and following space(s)
      comment = line.split(/#\s*/)[1]
      # Split that content into an array of words
      words = comment.split(" ")
      # Build up an array of new lines, where each line won't be longer than the line-length limit
      lines = words.reduce([line_prefix]) do |memo, word|
        previous_lines = memo[0..-2] # all lines but the current one
        current_line = memo.last
        word_appended = "#{current_line} #{word}"
        # if the line (with the current word appended) is too long, start a new line, prefixed
        # with a "#" and the right number spaces before it
        if word_appended.length > comment_limit
          next_line = "#{line_prefix} #{word}"
          memo.concat([next_line])
        else
          previous_lines.concat([word_appended])
        end
      end

      lines.join("\n")
    end

    # If a flag was given, return that. Otherwise, ask the user with `yes?`
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
