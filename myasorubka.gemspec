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
  spec.homepage      = 'https://github.com/dustalov/myasorubka'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
end
