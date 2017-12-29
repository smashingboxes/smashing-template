# The purpose of this file is to extend the steps used to create a new rails app. If you want to
# override an action in the existing setup, use AppBuilder
require 'rails/generators'
require 'rails/generators/rails/app/app_generator'

# Boxcar::AppGenerator
#   inherits Rails::Generators::AppGenerator
#     (https://github.com/rails/rails/blob/master/railties/lib/rails/generators/rails/app/app_generator.rb)
#   inherits Rails::Generators::AppBase
#     (https://github.com/rails/rails/blob/master/railties/lib/rails/generators/app_base.rb)
#   inherits Rails::Generators::Base
#     (https://github.com/rails/rails/blob/master/railties/lib/rails/generators/base.rb)
#     includes Rails::Generators::Actions
#       (https://github.com/rails/rails/blob/master/railties/lib/rails/generators/actions.rb)
#   inherits Thor::Group
#     (https://github.com/erikhuda/thor/blob/master/lib/thor/group.rb)

# Because we're inheriting from Thor::Group, all methods are run in the order they're defined in here:
# https://github.com/rails/rails/blob/master/railties/lib/rails/generators/rails/app/app_generator.rb#L279

module Boxcar
  module Commands
    class New < Rails::Generators::AppGenerator
      def finish_template
        invoke :boxcar_customization
        super
      end

      def boxcar_customization
        # Extensions go here
        # invoke :extra_thing_to_do
      end

      # def extra_thing_to_do
      # end

      protected

      def get_builder_class
        ::Boxcar::AppBuilder
      end
    end
  end
end
