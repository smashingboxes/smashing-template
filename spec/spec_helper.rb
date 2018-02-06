require "bundler/setup"
require "pry-byebug"

Bundler.require(:default, :test)

boxcar_path = (Pathname.new(__FILE__).dirname + "../lib/boxcar").expand_path

require boxcar_path

Dir["./spec/support/**/*.rb"].each { |file| require file }

RSpec.configure do |config|
  config.include ThorHelpers
  config.include BoxcarTestHelpers

  config.before(:all) do
    create_tmp_directory
  end
end
