# frozen_string_literal: true

require 'kommando'

module Superbot
  DOMAIN = ENV.fetch('SUPERBOT_DOMAIN', 'superbot.cloud')
  URI_SCHEME = ENV.fetch('SUPERBOT_URI_SCHEME', 'https')

  WEBDRIVER_ENDPOINT = {
    cloud: "#{URI_SCHEME}://webdriver.#{DOMAIN}",
    local: "http://127.0.0.1:9515",
    local_cloud: "http://localhost:3200"
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

require "clamp"
# TODO
Clamp.allow_options_after_parameters = true

require_relative "superbot/version"
require_relative "superbot/cli/validations"
%w(selenium cloud teleport runner record).each do |microgem|
  begin
    require "superbot/#{microgem}"
  rescue LoadError
    p # do nothing
  end
end

require_relative "superbot/project"
require_relative "superbot/cli"
require_relative "superbot/web"
