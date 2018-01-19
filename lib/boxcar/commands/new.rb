require "rails/generators"
require "rails/generators/rails/app/app_generator"

# The purpose of this class is to control the overall process of creating the rails app. We're
# inheriting from Rails::Generators::AppGenerator which is the default app generator
# (ie `rails new`). It, in turn, inherits from Thor::Group (a few steps up the chain), which means
# that all of the steps defined in it are run in the order they're defined.
#
# One thing to note: This class controls the generation of the app, but AppBuilder is the class
# that does the work of creating the files, and setting configs. The only methods we should be
# calling here are `invoke` (to call another method in this class) and `build` (to call methods
# in `AppBuilder`).
module Boxcar
  module Commands
    class New < Rails::Generators::AppGenerator
      class_option :skip_test, type: :boolean, default: true, desc: "Skip Test Unit"
      class_option :skip_spring, type: :boolean, default: true, desc: "Skip Spring"
      class_option :skip_tape, type: :boolean, default: false, desc: "Skip setting up the tape gem"
      class_option :active_admin, type: :boolean, desc: "Include active admin?"

      def finish_template
        invoke :boxcar_customization
        super
      end

      def boxcar_customization
        # Extensions go here
        invoke :setup_secrets
        invoke :setup_test_environment
        invoke :setup_tape
        invoke :setup_active_admin
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
        if builder.gem_config[:tape]
          say "Setting up Tape"
          build :install_tape
        end
      end

      def setup_active_admin
        if builder.gem_config[:activeadmin]
          say "Installing active admin"
          build :install_active_admin
        end
      end

      def setup_linter
        say "Setting up the linter"
        build :create_rubocop_config
        build :rubocop_autocorrect
        build :cleanup_other_linter_violations
      end

      protected

      def get_builder_class # rubocop:disable Naming/AccessorMethodName
        ::Boxcar::AppBuilder
      end
    end
  end
end
