# frozen_string_literal: true

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

    def ruby_version
      template ".ruby-version.erb", ".ruby-version"
    end

    def gemfile
      template "Gemfile.erb", "Gemfile", gem_configs
    end

    def database_yml
      template "database.yml.erb", "config/database.yml"
    end

    def create_secrets
      remove_file "config/secrets.yml"
      copy_boxcar_template "config/secrets.yml"
      copy_boxcar_template ".env.example"
      run "cp .env.example .env"
    end

    def generate_rspec
      generate "rspec:install"
      install_specs
    end

    def generate_capybara
      copy_boxcar_template "spec/support/capybara.rb"
      copy_boxcar_template "spec/system/home_page_spec.rb"
      copy_boxcar_template "app/views/shared/home.html.erb"
      replace_generated_default_file "app/controllers/application_controller.rb"
    end

    def install_specs
      copy_boxcar_template "spec/seeds/seed_spec.rb"
    end

    def create_query_traces
      copy_boxcar_template "config/initializers/query_trace.rb"
    end

    def configure_rspec
      remove_file "spec/rails_helper.rb"
      remove_file "spec/spec_helper.rb"
      copy_boxcar_template "spec/rails_helper.rb"
      copy_boxcar_template "spec/spec_helper.rb"
    end

    def create_database_cleaner_config
      copy_boxcar_template "spec/support/database_cleaner.rb"
    end

    def create_factory_bot_config
      copy_boxcar_template "spec/support/factory_bot.rb"
    end

    def create_shoulda_matchers_config
      copy_boxcar_template "spec/support/shoulda_matchers.rb"
    end

    def create_request_helpers_config
      copy_boxcar_template "spec/support/request_helpers.rb"
    end

    def install_tape
      run "tape installer install --no-vagrant"
      gsub_file "taperole/tape_vars.yml", /app_name:/, "app_name: #{app_name.underscore}"
    end

    def remove_asset_pipeline
      remove_directory "app/assets"
    end

    def install_activeadmin
      generate "active_admin:install --skip-users --skip-comments"
      copy_boxcar_template "spec/system/active_admin_spec.rb"
      split_long_comments "config/initializers/active_admin.rb"
      gsub_file "app/admin/dashboard.rb", "end # content", "end"
    end

    def install_devise
      generate "devise:install"
      generate "devise User"
      remove_file "app/models/user.rb"
      template "user.rb.erb", "app/models/user.rb", gem_configs
      gsub_file "config/initializers/devise.rb", /# config.secret_key.*/, "# config.secret_key = ''"
      gsub_file "config/initializers/devise.rb", /# config.pepper.*/, "# config.pepper = ''"
    end

    def install_flipper
      if gem_configs[:devise]
        copy_boxcar_template "config/initializers/flipper_routing_constraints.rb"
      end

      copy_boxcar_template "config/initializers/flipper_ui.rb"
      copy_boxcar_template "config/initializers/flipper.rb"
      generate "flipper:active_record"
    end

    def install_devise_token_auth
      generate "devise_token_auth:install User auth"
      # This does two things different from the default.
      # 1. It inherits from ApplicationRecord instead of ActiveRecord::Base
      # 2. It doesn't include omniauthable by default
      template "user.rb.erb", "app/models/user.rb", gem_configs
      copy_boxcar_template "spec/factories/users_factory.rb"
    end

    def create_routes
      remove_file "config/routes.rb"
      template "routes.rb.erb", "config/routes.rb", gem_configs
    end

    def force_ssl
      gsub_file(
        "config/environments/production.rb",
        "# config.force_ssl = true",
        "config.force_ssl = true"
      )
    end

    def create_devise_token_auth_helpers
      devise_controller
      render_helper
      spec_request_helper
      spec_auth_helpers
      auth_specs
    end

    def create_github_markdown
      copy_file "pull_request_template.md", ".github/pull_request_template.md"
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

    def create_erd_config
      copy_file ".erdconfig", ".erdconfig"
    end

    def create_api_controller
      copy_file "api_controller.rb", "app/controllers/api/v1/api_controller.rb"
    end

    def devise_controller
      copy_file "devise_token_auth_response_serializer.rb",
                "app/controllers/concerns/devise_token_auth_response_serializer.rb"
      copy_file "registrations_controller.rb",
                "app/controllers/api/v1/users/registration_controller.rb"
      copy_file "sessions_controller.rb", "app/controllers/api/v1/users/sessions_controller.rb"
    end

    def setup_database
      run "rails db:create"
    end

    def migrate_database
      run "rails db:migrate"
    end

    def setup_annotate
      copy_boxcar_template "lib/tasks/auto_annotate_models.rake"
    end

    def setup_bullet
      copy_boxcar_template "config/initializers/bullet.rb"
    end

    def setup_seeds
      remove_file "db/seeds.rb"
      copy_file "boxcar/db/seeds.rb", "db/seeds.rb"
      copy_file "boxcar/db/seeds/user_seeds.rb", "db/seeds/user_seeds.rb"
    end

    def setup_action_mailer
      development_action_mailer_config = <<~CONFIG

        config.action_mailer.delivery_method = :letter_opener
        config.action_mailer.perform_deliveries = true

        config.action_mailer.default_url_options = { host: "localhost", port: 3000 }

      CONFIG

      insert_into_file "config/environments/development.rb",
                       development_action_mailer_config,
                       before: "# Don't care if the mailer can't send."

      production_action_mailer_config = <<~CONFIG

        config.action_mailer.default_url_options = {
          host: Rails.application.secrets.mailgun_domain
        }

        config.action_mailer.delivery_method = :mailgun

        config.action_mailer.mailgun_settings = {
          api_key: Rails.application.secrets.mailgun_api_key,
          domain: Rails.application.secrets.mailgun_domain
        }

      CONFIG

      insert_into_file "config/environments/production.rb",
                       production_action_mailer_config,
                       before: "config.action_mailer.perform_caching = false"
    end

    def setup_procfile
      template "Procfile.erb", "Procfile", api_app: boxcar_configs[:api_app]
    end

    def setup_webpacker
      run "rails webpacker:install"
      run "rails webpacker:install:react"
      replace_generated_default_file("config/webpacker.yml")
    end

    def setup_boilerplate_app
      replace_generated_directory "app/views"
      replace_generated_directory "app/javascript"
    end

    def create_rubocop_config
      copy_file ".rubocop.yml", ".rubocop.yml"
    end

    def create_eslint_config
      run "curl https://raw.githubusercontent.com/smashingboxes/web-boilerplate/master/.eslintrc -O"
      copy_boxcar_template ".eslintrc"
    end

    def create_stylelint_config
      copy_boxcar_template "stylelint.config.js"
    end

    def setup_package_json
      remove_file "package.json"
      template "package.json.erb", "package.json"
      run "yarn install"
    end

    def rubocop_autocorrect
      run "rubocop -a", capture: true
    end

    def cleanup_other_rubocop_violations
      split_long_comments "config/initializers/backtrace_silencers.rb"
      split_long_comments "config/environments/production.rb"
    end

    def cleanup_eslint_violations
      # noop, but keeping this method because we might have stuff in the future
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
        gems[:flipper] = preference?(:flipper, "Install Flipper? (y/N)")
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

    def eslint_disable_file(filename)
      prepend_to_file filename, "/* eslint-disable */"
      append_to_file filename, "/* eslint-enable */\n"
    end

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

    def copy_boxcar_template(destination, boxcar_template_location = nil)
      boxcar_template_location ||= "boxcar/#{destination}"
      copy_file boxcar_template_location, destination
    end

    def replace_generated_default_file(path, boxcar_template_location = nil)
      remove_file path
      copy_boxcar_template path, boxcar_template_location
    end

    def copy_boxcar_directory(directory, boxcar_directory_location = nil)
      boxcar_directory_location ||= "boxcar/#{directory}"
      directory boxcar_directory_location, directory
    end

    def replace_generated_directory(directory, boxcar_directory_location = nil)
      remove_directory directory
      boxcar_directory_location ||= "boxcar/#{directory}"
      directory boxcar_directory_location, directory
    end

    def remove_directory(directory)
      run "rm -rf #{directory}"
    end

    # This is necessary because the default `generate` runs the default `run` instead of our run
    def generate(command)
      run "rails generate #{command}"
    end
  end
end
