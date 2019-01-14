# frozen_string_literal: true

module Superbot
  module Validations
    def validates_project_path(path)
      unless Dir.exist? path
        raise ArgumentError, "directory #{path} does not exist"
      end

      entrypoint = File.join path, "main.rb"
      unless File.exist? entrypoint
        raise ArgumentError, "file #{entrypoint} does not exist"
      end

      path
    end
  end
end
