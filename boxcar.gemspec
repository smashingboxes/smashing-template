# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)
require "boxcar/version"
require "date"

Gem::Specification.new do |s|
  s.required_ruby_version = ">= #{Boxcar::RUBY_VERSION}"
  s.authors = ["Smashing Boxes"]
  s.date = Date.today.strftime("%Y-%m-%d")

  s.description = "Boxcar is a Rails project generator used by Smashing Boxes"

  s.email = "dev@smashingboxes.com"
  s.executables = ["boxcar"]
  s.extra_rdoc_files = %w[README.md LICENSE]
  s.files = `git ls-files`.split("\n")
  s.homepage = "http://github.com/smashingboxes/boxcar"
  s.license = "MIT"
  s.name = "boxcar"
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.summary = "Generate a Rails app using the defaults for Smashing Boxes."
  s.test_files = `git ls-files -- spec/*`.split("\n")
  s.version = Boxcar::VERSION

  s.add_dependency "bundler", "~> 1.3"
  s.add_dependency "rails", Boxcar::RAILS_VERSION

  s.add_development_dependency "pry-byebug"
  s.add_development_dependency "rspec", "~> 3.2"
  s.add_development_dependency "rubocop", "~> 0.54"
  s.add_development_dependency "rubocop-rspec", "~> 1.25"
end
