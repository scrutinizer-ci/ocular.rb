# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scrutinizer/ocular/version'

Gem::Specification.new do |spec|
  spec.name          = "scrutinizer-ocular"
  spec.version       = Scrutinizer::Ocular::VERSION
  spec.authors       = ["Scrutinizer"]
  spec.email         = ["support@scrutinizer-ci.com"]
  spec.summary       = %q{Uploads code coverage data to scrutinizer-ci.com}
  spec.description   = %q{Simple gem that uploads coverage data from a CI server; also handles submissions from parallelized runs.}
  spec.homepage      = "https://scrutinizer-ci.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]


  if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('1.9')
    spec.add_dependency 'simplecov', '>= 0.7'
  end

  spec.add_runtime_dependency('jruby-openssl') if RUBY_PLATFORM == 'java'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
