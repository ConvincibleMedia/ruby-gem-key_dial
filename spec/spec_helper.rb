require "bundler/setup"
require "key_dial"
require 'ice_nine'
require 'ice_nine/core_ext/object'
require "active_support/core_ext/object/deep_dup"
require 'pry'; require 'pry-nav'
def peep(var); Pry::ColorPrinter.pp(var); end
$debug = false;

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
