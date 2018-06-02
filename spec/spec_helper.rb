require "bundler/setup"

require "simplecov"
SimpleCov.at_exit do
  SimpleCov.result.format!
end
SimpleCov.minimum_coverage 100
SimpleCov.minimum_coverage_by_file 100
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/lib/superbot/cli/"
end

require "superbot"
require "kommando"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
