# frozen_string_literal: true

module Superbot
  module CLI
    class RunCommand < Clamp::Command
      parameter "PATH", "project directory" do |path|
        unless Dir.exist? path
          raise ArgumentError, "directory #{path} does not exist"
        end

        entrypoint = File.join path, "main.rb"
        unless File.exist? entrypoint
          raise ArgumentError, "file #{entrypoint} does not exist"
        end

        path
      end

      def execute
        ""
      end
    end
  end
end
