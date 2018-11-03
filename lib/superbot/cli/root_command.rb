# frozen_string_literal: true

require_relative "new_command"
require_relative "run_command"
require_relative "teleport_command"
require_relative "version_command"

module Superbot
  module CLI
    class RootCommand < Clamp::Command
      banner "superbot 🤖"

      subcommand ["new"], "Create a new project", NewCommand
      subcommand ["run"], "Run a project", RunCommand
      subcommand ["version"], "Show version information", VersionCommand
      subcommand ["teleport"], "Open a teleport for superbots", TeleportCommand

      def self.run
        super
      rescue StandardError => exc
        warn exc.message
        warn exc.backtrace.join("\n")
      end

      def subcommand_missing(name)
        return super unless %w(cloud local).include?(name)

        abort "Subcommand '#{name}' requires gem superbot-#{name} to be installed"
      end
    end
  end
end
