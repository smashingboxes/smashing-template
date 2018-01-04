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

      def finish_template
        invoke :boxcar_customization
        super
      end

      def boxcar_customization
        # Extensions go here
        invoke :setup_test_environment
        invoke :create_database
      end

      def setup_test_environment
        say "Setting up the test environment"
        build :generate_rspec
        build :create_database_cleaner_config
        build :create_factory_bot_config
        build :configure_travis
      end

      def create_database
        say "Setting up the test environment"
        build :create_database
      end

      protected

      def get_builder_class # rubocop:disable Naming/AccessorMethodName
        ::Boxcar::AppBuilder
      end
    end
  end
end
