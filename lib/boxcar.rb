require "thor"

module Boxcar
  autoload :VERSION, "boxcar/version"
  autoload :RUBY_VERSION, "boxcar/version"
  autoload :RAILS_VERSION, "boxcar/version"

  autoload :Actions, "boxcar/actions"
  autoload :AppBuilder, "boxcar/app_builder"

  module Commands
    autoload :Boxcar, "boxcar/commands/boxcar"
    autoload :New, "boxcar/commands/new"
  end
end

templates_root = File.expand_path(File.join("..", "templates"), File.dirname(__FILE__))
Boxcar::Commands::New.source_root(templates_root)
Boxcar::Commands::New.source_paths << Rails::Generators::AppGenerator.source_root << templates_root
