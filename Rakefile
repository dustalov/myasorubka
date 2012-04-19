# encoding: utf-8

require 'rubygems'

require 'bundler/setup'
Bundler.require(:default)

require 'unicode_utils/downcase'
require 'unicode_utils/upcase'

$:.unshift File.expand_path('../lib', __FILE__)
require 'myasorubka'

config = {
  path: ENV['path'] || nil
}

desc 'Convert the AOT dictionaries'
task :aot do
  config[:mrd] = ENV['mrd'] or
    raise ArgumentError, "ENV['mrd'] is not set"

  config[:tab] = ENV['tab'] or
    raise ArgumentError, "ENV['tab'] is not set"

  config[:language] = ENV['language'] && ENV['language'].to_sym or
    raise ArgumentError, "ENV['language'] is not set"

  config[:encoding] = ENV['encoding'] || 'CP-1251'

  require 'myasorubka/aot'
  Myasorubka.new(config.merge(adapter: Myasorubka::AOT)).run!
end

desc 'Cleanup'
task :clean do
  %w(dex lex tct).
    map { |ext| Dir['*.%s' % ext] }.
    flatten.
    each { |path| rm_f path }
end

task :default => :aot
