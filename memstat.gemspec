# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'memstat/version'

Gem::Specification.new do |spec|
  spec.name          = 'memstat'
  spec.version       = Memstat::VERSION
  spec.authors       = ['Kenn Ejima']
  spec.email         = ['kenn.ejima@gmail.com']
  spec.description   = %q{Fast memory statistics and better out-of-band GC}
  spec.summary       = %q{Fast memory statistics and better out-of-band GC}
  spec.homepage      = 'https://github.com/kenn/memstat'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'

  spec.add_runtime_dependency 'thor'
end
