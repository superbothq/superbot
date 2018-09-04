# frozen_string_literal: true

require 'singleton'

module Superbot
  class Project
    include Singleton
    attr_accessor :path

    def self.path=(path)
      instance.path = path
    end

    def self.path
      instance.path
    end
  end
end
