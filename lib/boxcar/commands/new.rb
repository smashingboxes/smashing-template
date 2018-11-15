# frozen_string_literal: true

require "rails/generators"
require "rails/generators/rails/app/app_generator"

# The purpose of this class is to control the overall process of creating the rails app. We're
# inheriting from Rails::Generators::AppGenerator which is the default app generator
# (i.e. `rails new`). It, in turn, inherits from Thor::Group (a few steps up the chain), which means
# that all of the steps defined in it are run in the order they're defined.
#
# One thing to note: This class controls the generation of the app, but AppBuilder is the class
# that does the work of creating the files, setting configs, etc. The only methods we should be
# calling here are `invoke` (to call another method in this class) and `build` (to call methods
# in `AppBuilder`).
#
# Adding new functionality should be placed in the boxcar_customization function.  Please invoke
# the new functionality like the commands in boxcar_customization function.
module Boxcar
  module Commands
    class New < Rails::Generators::AppGenerator
      class_option :skip_test, type: :boolean, default: true, desc: "Skip Test Unit"
      class_option :skip_spring, type: :boolean, default: true, desc: "Skip Spring"
      class_option :skip_tape, type: :boolean, default: false, desc: "Skip setting up the tape gem"
      class_option :skip_turbolinks, type: :boolean, default: true, desc: "Skip Turbolinks"
      class_option :api_only, type: :boolean, desc: "API only app?"
      class_option :activeadmin, type: :boolean, desc: "Install active admin?"
      class_option :devise, type: :boolean, desc: "Install devise?"
      class_option :devise_token_auth, type: :boolean, desc: "Install devise_token_auth?"
      class_option :flipper, type: :boolean, desc: "Install Flipper?"

      # We're overriding run_after_bundle_callbacks because it's almost the last thing that the
      # rails generator does, and it's where we want to do our custom behavior
      def run_after_bundle_callbacks
        super
        invoke :boxcar_customization
      end

      def boxcar_customization
        # Extensions go here
        invoke :setup_ruby_version
        invoke :setup_secrets
        invoke :setup_test_environment
        invoke :setup_tape
        invoke :remove_asset_pipeline
        invoke :setup_activeadmin # Must come after remove_asset_pipeline or AA will be removed
        invoke :setup_database
        invoke :setup_api_controller # Must come before setup_devise
        invoke :setup_devise
        invoke :setup_annotate
        invoke :setup_flipper
        invoke :setup_bullet
        invoke :setup_action_mailer
        invoke :setup_seeds
        invoke :migrate_database
        invoke :setup_github_template
        invoke :setup_routes
        invoke :setup_erd_template
        invoke :setup_procfile
        invoke :setup_webpacker
        invoke :setup_package_json
        invoke :setup_boilerplate_app
        invoke :setup_linters # This line should be last
      end

      def setup_routes
        build :create_routes
      end

      def setup_secrets
        say "Setting up secrets"
        build :create_secrets
      end

      def setup_ruby_version
        say "Setting up .ruby_version"
        build :ruby_version
      end

      def setup_erd_template
        say "Adding the erd config file"
        build :create_erd_config
      end

      def setup_github_template
        say "Adding the github template"
        build :create_github_markdown
      end

      def setup_test_environment
        say "Setting up the test environment"
        build :generate_rspec
        build :generate_capybara
        build :configure_rspec
        build :create_database_cleaner_config
        build :create_factory_bot_config
        build :create_shoulda_matchers_config
        build :create_request_helpers_config
        build :configure_travis
      end

      def setup_tape
        return unless builder.gem_configs[:tape]

        say "Setting up tape"
        build :install_tape
      end

      def remove_asset_pipeline
        say "Removing asset pipeline"
        build :remove_asset_pipeline
      end

      def setup_activeadmin
        return unless builder.gem_configs[:activeadmin]

        say "Installing active admin"
        build :install_activeadmin
      end

      def setup_database
        say "Setting up database"
        build :setup_database
      end

      def migrate_database
        say "Migrating database"
        build :migrate_database
      end

      def setup_api_controller
        say "Setting up API controller"
        build :create_api_controller
      end

      def setup_devise
        if builder.gem_configs[:devise]
          say "Installing devise"
          build :install_devise
        elsif builder.gem_configs[:devise_token_auth]
          say "Installing devise_token_auth"
          build :install_devise_token_auth
          build :create_devise_token_auth_helpers
        end
      end

      def setup_seeds
        say "Setting up seeds file"
        build :setup_seeds
      end

      def setup_flipper
        return unless builder.gem_configs[:flipper]

        say "Setting up Flipper"
        build :install_flipper
      end

      def setup_action_mailer
        say "Setting up ActionMailer"
        build :setup_action_mailer
      end

      def setup_annotate
        say "Setting up annotate"
        build :setup_annotate
      end

      def setup_procfile
        say "Setting up Procfile"
        build :setup_procfile
      end

      def setup_bullet
        say "Setting up bullet"
        build :setup_bullet
      end

      def setup_package_json
        say "Setting up package.json"
        build :setup_package_json
      end

      def setup_webpacker
        return if builder.boxcar_configs[:api_app]

        say "Setting up webpacker"
        build :setup_webpacker
      end

      def setup_boilerplate_app
        return if builder.boxcar_configs[:api_app]

        say "Setting up boilerplate react app"
        build :setup_boilerplate_app
      end

      def setup_linters
        say "Setting up the linter configs"
        build :create_rubocop_config
        build :rubocop_autocorrect
        build :cleanup_other_rubocop_violations
        build :create_eslint_config
        build :cleanup_eslint_violations
        build :create_stylelint_config
      end

      protected

      # rubocop:disable Naming/AccessorMethodName
      # We have no control over this name. It's defined by rails
      def get_builder_class
        ::Boxcar::AppBuilder
      end
      # rubocop:enable Naming/AccessorMethodName
    end
  end
end
