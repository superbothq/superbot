# frozen_string_literal: true

require_relative "new_command"
require_relative "run_command"
require_relative "teleport_command"
require_relative "version_command"

module Superbot
  module CLI
    class RootCommand < Clamp::Command
      banner "superbot 🤖"

      option ['-v', '--version'], :flag, "Show version information" do
        puts Superbot::VERSION
        exit(0)
      end

      subcommand ["version"], "Show version information", VersionCommand
      subcommand ["teleport"], "Open a teleport for superbots", TeleportCommand
      if ENV['SUPERBOT_FEAT_PROJECT'] == 'true'
        subcommand ["new"], "Create a new project", NewCommand
        subcommand ["run"], "Run a project", RunCommand
      end

      def self.run
        super
      rescue StandardError => exc
        warn exc.message
        warn exc.backtrace.join("\n")
      end

      def subcommand_missing(name)
        return super unless name == 'local'

        abort "Subcommand '#{name}' requires gem superbot-#{name} to be installed"
      end
    end
  end
end
