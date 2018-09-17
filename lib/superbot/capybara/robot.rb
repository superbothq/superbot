# frozen_string_literal: true

module Superbot
  module Capybara
    class Robot
      def initialize(script)
        @script = script
      end

      def self.run(*args)
        new(*args).run
      end

      def run
        run_script
      end

      private

      attr_accessor :script

      def run_script
        gem 'superbot-capybara'

        k = Kommando.new "sb-capybara"
        k.in.writeln({ eval: script }.to_json)

        finished = false
        k.out.once /(error|ok)/x do
          finished = true
        end

        k.run_async

        loop do
          break if finished

          sleep 0.001
        end
        k.kill
      rescue Gem::LoadError
        puts "superbot-capybara not installed"
      end
    end
  end
end
