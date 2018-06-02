# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "kommando"

RSpec::Core::RakeTask.new(:spec)

task default: [:rubocop, :spec]

task :rubocop do
  Kommando.puts "rubocop"
end
