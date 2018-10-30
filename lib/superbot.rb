# frozen_string_literal: true

module Superbot
  WEBDRIVER_ENDPOINT = {
    cloud: "http://webdriver.superbot.cloud:3000/webdriver/v1",
    local: "http://127.0.0.1:9515"
  }.freeze
  private_constant :WEBDRIVER_ENDPOINT

  CLOUD_TIMEOUT = 2000
  private_constant :CLOUD_TIMEOUT

  def self.test_run?
    ENV["SUPERBOT_TEST_RUN"] == "true"
  end

  def self.webdriver_endpoint(type)
    WEBDRIVER_ENDPOINT[type.to_sym]
  end

  def self.cloud_timeout
    CLOUD_TIMEOUT
  end
end

require_relative "superbot/version"
require_relative "superbot/project"
require_relative "superbot/cli"
require_relative "superbot/web"
