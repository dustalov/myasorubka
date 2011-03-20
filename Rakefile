# encoding: utf-8

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, :development)

$:.unshift File.expand_path('../lib', __FILE__)
require 'myasorubka'

options = {}

task :options do
  options[:morphs] = ENV['morphs'] or
    raise ArgumentError, "ENV['morphs'] is not set."
  options[:gramtab] = ENV['gramtab'] or
    raise ArgumentError, "ENV['gramtab'] is not set."
  options[:encoding] = ENV['encoding']
end

desc 'Perform conversion'
task :convert => :options do
  Myasorubka::Converter.new(
    options[:morphs],
    options[:gramtab],
    options[:encoding]
  ).execute!
end

desc 'Cleanup'
task :clean do
  [ 'dec', 'lex', 'tct' ].each do |res|
    Dir.glob("*.#{res}") do |path|
      rm_f path
    end
  end
end

task :default => :convert
