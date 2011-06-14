# encoding: utf-8

require 'rubygems'

require 'bundler/setup'
Bundler.require(:default)

$:.unshift File.expand_path('../lib', __FILE__)
require 'myasorubka'

configuration = {
  :path => ENV['path'] || nil
}

desc 'Convert the AOT project dictionaries'
task :aot do
  configuration[:mrd] = ENV['mrd'] or raise ArgumentError,
    "ENV['mrd'] is not set."
  configuration[:tab] = ENV['tab'] or raise ArgumentError,
    "ENV['tab'] is not set."
  configuration[:language] = ENV['encoding'] or raise ArgumentError
  configuration[:language] = configuration[:language].to_sym
  configuration[:encoding] = ENV['encoding'] || 'CP-1251'

  require 'myasorubka/adapters/aot'
  Myasorubka::Processor.new(configuration.merge(
    {
      :adapter => Myasorubka::AOT
    }
  )).run!
end

desc 'Cleanup'
task :clean do
  [ 'dec', 'lex', 'tct' ].each do |res|
    Dir.glob("*.#{res}") do |path|
      rm_f path
    end
  end
end

task :default => :list
