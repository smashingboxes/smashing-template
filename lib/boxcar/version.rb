module Boxcar
  RAILS_VERSION = "~> 5.1.4".freeze
  RUBY_VERSION = IO
    .read("#{File.dirname(__FILE__)}/../../.ruby-version")
    .strip
    .freeze
  VERSION = "0.0.1".freeze
end
