# frozen_string_literal: true

require 'zaru'
require 'fileutils'

module Superbot
  module CLI
    class NewCommand < Clamp::Command
      parameter "PATH", "path name to create" do |path|
        unless path == Zaru.sanitize!(path)
          raise ArgumentError, "#{path} is not valid name for a directory"
        end

        if Dir.exist? path
          raise ArgumentError, "directory #{path} already exists"
        end

        if File.exist? path
          raise ArgumentError, "#{path} is an existing file"
        end

        path
      end

      def execute
        FileUtils.mkdir path
        File.write File.join(path, "main.rb"), "visit \"example.com\"\n"

        puts """🤖 created directory #{path} with main.rb

Start testing with:

  superbot run #{path}
"""
      end
    end
  end
end
