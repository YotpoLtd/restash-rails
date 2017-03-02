# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'restash_rails/version'

Gem::Specification.new do |spec|
  spec.name          = 'restash_rails'
  spec.version       = RestashRails::VERSION
  spec.authors       = ['dmitri86git']
  spec.email         = ['dmitri@yotpo.com']

  spec.summary       = 'This gem sends your Rails application logs to logstash.'
  spec.description   = 'Add configurations to application.config.restash_rails and  have fun.'
  spec.homepage      = 'https://github.com/YotpoLtd/restash-rails'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject{ |f|  f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_dependency 'rails'
  spec.add_dependency 'tcp_timeout'
end
