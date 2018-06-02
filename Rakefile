# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "kommando"

RSpec::Core::RakeTask.new(:spec)

task default: %i[rubocop spec e2e]

task :rubocop do
  rubocop_k = Kommando.puts "rubocop"
  puts "" # styling for rake
  raise "offenses found" unless rubocop_k.code.zero?
end

task :e2e do
  e2e_k = Kommando.run "bin/e2e"
  if e2e_k.code.zero?
    puts "bin/e2e ok 🤖"
  else
    puts e2e_k.out
    raise "e2e exists with non-zero"
  end
end
