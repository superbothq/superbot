# frozen_string_literal: true

require_relative "new_command"
require_relative "run_command"
require_relative "version_command"

module Superbot
  module CLI
    class RootCommand < Clamp::Command
      banner "superbot 🤖"

      subcommand ["new"], "Create a new project", NewCommand
      subcommand ["run"], "Run a project", RunCommand
      subcommand ["version"], "Show version information", VersionCommand

      def self.run
        super
      rescue StandardError => exc
        warn exc.message
        warn exc.backtrace.join("\n")
      end
    end
  end
end
