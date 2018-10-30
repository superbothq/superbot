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

    def validates_browser_type(browser)
      unless %w(local cloud).include?(browser)
        raise ArgumentError, "The '#{browser}' browser option is not allowed. Should be either 'local' or 'cloud'."
      end

      browser
    end
  end
end
