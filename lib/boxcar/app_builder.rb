# The purpose of this file is to override parts of the default rails setup process. To add new
# steps, use Boxcar::Commands::New
module Boxcar
  class AppBuilder < Rails::AppBuilder
    include Boxcar::Actions

    def readme
      template 'README.md.erb', 'README.md'
    end
  end
end
