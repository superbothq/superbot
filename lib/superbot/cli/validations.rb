# frozen_string_literal: true

module Superbot
  module Validations
    def validates_project_path(path)
      signal_usage_error "directory #{path} does not exist" unless Dir.exist? path

      path
    end
  end
end
