require "bundler/setup"

require "simplecov"
SimpleCov.at_exit do
  SimpleCov.result.format!
end
SimpleCov.minimum_coverage 0
SimpleCov.minimum_coverage_by_file 0
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/lib/superbot/cli/"
  add_filter "/lib/superbot/validations.rb"
  add_filter "/lib/superbot/web.rb"
  add_filter "/lib/superbot/project.rb"
  add_filter "/lib/superbot/capybara"
end

require "superbot"
require "net/http"
require "excon"

ENV["SUPERBOT_TEST_RUN"] = "true"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = :random
end

def http_get(url)
  Net::HTTP.get URI(url)
end

def wait_web
  begin
    http_get "http://localhost:4567/__superbot/v1/ping"
  rescue
    sleep 0.01
    retry
  end
end

def http_post_json(url, payload)
  response = Excon.post(url, {
    headers: {
      "Content-Type" => "application/json"
    },
    body: payload.to_json
  })

  response
end

def superbot(*cmds)
  k = superbot_new cmds
  k.run
  k
end

def superbot_new(*cmds_and_last_may_be_opts)
  cmds, opts = if cmds_and_last_may_be_opts.last.is_a? Hash
    last_one = cmds_and_last_may_be_opts.pop
    before_that = cmds_and_last_may_be_opts
    [before_that, last_one]
  else
    [cmds_and_last_may_be_opts, {}]
  end

  Kommando.new "exe/superbot #{cmds.join(" ")}", opts
end

def superbot_test_path(name="default")
  "__test_#{name}_#{ENV['TEST_ENV_NUMBER'].to_i}"
end

RSpec.shared_examples "run / dev errors" do
  around do |example|
    FileUtils.mkdir superbot_test_path("empty_dir") unless Dir.exist? superbot_test_path("empty_dir")
    example.call
    FileUtils.rm_r superbot_test_path("empty_dir") if Dir.exist? superbot_test_path("empty_dir")
  end

  it do
    @k = superbot "run", superbot_test_path("nonexisting_dir")
    expect(@k.code).to eq 1
    expect(@k.out).to include "directory #{superbot_test_path("nonexisting_dir")} does not exist"
  end

  it do
    @k = superbot "run", superbot_test_path("empty_dir")
    expect(@k.code).to eq 1
    expect(@k.out).to include "file #{superbot_test_path("empty_dir")}/main.rb does not exist"
  end
end
