# frozen_string_literal: true

require_relative "version_command"
require_relative "new_command"

module Superbot
  module CLI
    class RootCommand < Clamp::Command
      banner "superbot 🤖"

      subcommand ["version"], "Show version information", VersionCommand
      subcommand ["new"], "Create a new project", NewCommand

      def self.run
        super
      rescue StandardError => exc
        warn exc.message
        warn exc.backtrace.join("\n")
      end
    end
  end
end
