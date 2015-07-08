# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'swiftype-monitoring/version'

Gem::Specification.new do |spec|
  spec.name          = "swiftype-monitoring"
  spec.version       = SwiftypeMonitoring::VERSION
  spec.authors       = ["Swiftype Technical Operations Team"]
  spec.email         = ["ops@swiftype.com"]

  spec.summary       = %q{Swiftype Monitoring APIs}
  spec.description   = %q{Useful collection for writing monitoring checks/scripts for Swiftype infrastructure.}
  spec.homepage      = "https://swiftype.com/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"

  # Sensu plugins API
  spec.add_dependency 'sensu-plugin'

  # Some service clients we may need
  spec.add_dependency 'mysql2'
  spec.add_dependency 'elasticsearch'
  spec.add_dependency 'redis'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'kjess'
end
