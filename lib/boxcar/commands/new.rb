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
module Boxcar
  module Commands
    class New < Rails::Generators::AppGenerator
      class_option :skip_test, type: :boolean, default: true, desc: "Skip Test Unit"
      class_option :skip_spring, type: :boolean, default: true, desc: "Skip Spring"
      class_option :skip_tape, type: :boolean, default: false, desc: "Skip setting up the tape gem"
      class_option :api_only, type: :boolean, desc: "API only app?"
      class_option :activeadmin, type: :boolean, desc: "Install active admin?"
      class_option :devise, type: :boolean, desc: "Install devise?"
      class_option :devise_token_auth, type: :boolean, desc: "Install devise_token_auth?"

      # We're overriding run_after_bundle_callbacks because it's almost the last thing that the
      # rails generator does, and it's where we want to do our custom behavior
      def run_after_bundle_callbacks
        super
        invoke :boxcar_customization
      end

      def boxcar_customization
        # Extensions go here
        invoke :setup_secrets
        invoke :setup_test_environment
        invoke :setup_tape
        invoke :setup_activeadmin
        invoke :setup_database
        invoke :setup_devise
        invoke :setup_linter
      end

      def setup_secrets
        say "Setting up secrets"
        build :create_secrets_example
      end

      def setup_test_environment
        say "Setting up the test environment"
        build :generate_rspec
        build :configure_rspec
        build :create_database_cleaner_config
        build :create_factory_bot_config
        build :create_shoulda_matchers_config
        build :configure_travis
      end

      def setup_tape
        if builder.gem_configs[:tape]
          say "Setting up tape"
          build :install_tape
        end
      end

      def setup_activeadmin
        if builder.gem_configs[:activeadmin]
          say "Installing active admin"
          build :install_activeadmin
        end
      end

      def setup_database
        say "Setting up database"
        build :setup_database
      end

      def setup_devise
        if builder.gem_configs[:devise]
          say "Installing devise"
          build :install_devise
        elsif builder.gem_configs[:devise_token_auth]
          say "Installing devise_token_auth"
          build :install_devise_token_auth
        end
      end

      def setup_linter
        say "Setting up the linter"
        build :create_rubocop_config
        build :rubocop_autocorrect
        build :cleanup_other_linter_violations
      end

      protected

      def get_builder_class
        ::Boxcar::AppBuilder
      end
    end
  end
end
