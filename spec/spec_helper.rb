# encoding: utf-8

require 'rubygems'

$:.unshift File.expand_path('../../lib', __FILE__)

if RUBY_VERSION == '1.8'
  gem 'minitest'
end

require 'minitest/autorun'

require 'myasorubka'
require 'myasorubka/aot'
require 'myasorubka/msd/russian'

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |f| require f }
