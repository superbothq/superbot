# frozen_string_literal: true

STDOUT.sync = true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"
require "kommando"

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new(:spec)

task default: %i[rubocop spec e2e]

task :e2e do
  e2e_k = Kommando.run "bin/e2e"
  if e2e_k.code.zero?
    puts "bin/e2e ok 🤖"
  else
    puts e2e_k.out
    raise "e2e exists with non-zero"
  end
end
