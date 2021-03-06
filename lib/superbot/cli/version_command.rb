# frozen_string_literal: true

module Superbot
  module CLI
    class VersionCommand < Clamp::Command
      def execute
        puts Superbot::VERSION
      end
    end
  end
end
