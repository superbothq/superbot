# frozen_string_literal: true

module Superbot
  def self.test_run?
    ENV["SUPERBOT_TEST_RUN"] == "true"
  end
end

require_relative "superbot/version"
require_relative "superbot/project"
require_relative "superbot/cli"
require_relative "superbot/web"
