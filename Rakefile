require 'rubygems'
require 'bundler'
Bundler.setup

require 'rspec'
require 'rspec/core/rake_task'

desc "Run the specs for wesabot"
Rspec::Core::RakeTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

task :cruise => :spec
task :default => :spec