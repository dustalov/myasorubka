# encoding: utf-8

require 'rubygems'

$:.unshift File.expand_path('../../lib', __FILE__)

gem 'minitest'
require 'minitest/autorun'
require 'minitest/hell'

require 'myasorubka'
require 'myasorubka/aot'
require 'myasorubka/msd/russian'

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |f| require f }
