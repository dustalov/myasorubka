# encoding: utf-8

require 'rubygems/package_task'
require 'bundler/gem_tasks'

require 'rake/testtask'
Rake::TestTask.new do |test|
  test.pattern = 'spec/**/*_spec.rb'
  test.verbose = true
end

task :default => :test
