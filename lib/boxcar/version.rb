# frozen_string_literal: true

module Boxcar
  RAILS_VERSION = "~> 5.2.2"
  RUBY_VERSION = IO
                 .read("#{File.dirname(__FILE__)}/../../.ruby-version")
                 .strip
  VERSION = "0.0.1"
end
