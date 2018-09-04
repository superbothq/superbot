# frozen_string_literal: true

module Superbot
  module CLI
    class RunCommand < Clamp::Command
      include Superbot::Validations

      parameter "PATH", "project directory" do |path|
        validates_project_path path

        path
      end

      def execute
        web = Superbot::Web.new
        web.run_async_after_running!

        puts "🤖 active"
        puts ""
        puts "Press enter to exit"
        $stdin.gets
      end
    end
  end
end
