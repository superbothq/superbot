# frozen_string_literal: true

guard :rspec, cmd: "bundle exec rspec", all_after_pass: true do
  require "guard/rspec/dsl"
  dsl = Guard::RSpec::Dsl.new(self)

  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)

  watch %r{^lib\/superbot\/cli\/(?<command>.+)_command\.rb$} do |m|
    "spec/cli/commands/#{m[:command]}_spec.rb"
  end
end

guard :rubocop do
  watch(/.+\.rb$/)
  watch(%r{(?:.+/)?\.rubocop(?:_todo)?\.yml$}) { |m| File.dirname(m[0]) }
end
