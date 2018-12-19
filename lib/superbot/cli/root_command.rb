# frozen_string_literal: true

require_relative "new_command"
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
      subcommand ["new"], "Create a new project", NewCommand if ENV['SUPERBOT_FEAT_PROJECT'] == 'true'

      if defined?(Superbot::Record::CLI::RootCommand)
        subcommand ["record"], "Superbot recorder tools", ::Superbot::Record::CLI::RootCommand
      end

      if defined?(::Superbot::Runner::CLI::RootCommand)
        subcommand ["run"], "Run superbot scripts", ::Superbot::Runner::CLI::RootCommand
      end

      if defined?(::Superbot::Cloud::CLI::RootCommand)
        subcommand ["cloud"], "Show cloud commands", ::Superbot::Cloud::CLI::RootCommand
      end

      if defined?(::Superbot::Teleport::CLI::RootCommand)
        subcommand ["teleport"], "Open teleport to the cloud", ::Superbot::Teleport::CLI::RootCommand
      end

      def self.run
        super
      rescue StandardError => exc
        warn exc.message
        warn exc.backtrace.join("\n")
      end
    end
  end
end
