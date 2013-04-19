# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'myasorubka/version'

Gem::Specification.new do |spec|
  spec.name          = 'myasorubka'
  spec.version       = Myasorubka::VERSION
  spec.authors       = ['Dmitry Ustalov']
  spec.email         = ['dmitry@eveel.ru']
  spec.description   = 'Myasorubka is a morphological data processor.'
  spec.summary       = 'Myasorubka is a morphological data proceesor ' \
                       'that supports AOT and MULTEXT-East notations.'
  spec.homepage      = 'https://github.com/ustalov/myasorubka'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'minitest', '>= 2.11'
  spec.add_development_dependency 'rake'

  spec.add_dependency 'unicode_utils', '~> 1.4'
end
