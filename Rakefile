# frozen_string_literal: true

STDOUT.sync = true

require "bundler/gem_tasks"
require "rubocop/rake_task"
require "kommando"

RuboCop::RakeTask.new

task default: %i[rubocop spec e2e]

task :spec do
  system('rspec')
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
