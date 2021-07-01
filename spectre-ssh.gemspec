Gem::Specification.new do |spec|
  spec.name          = 'spectre-ssh'
  spec.version       = '1.0.0'
  spec.authors       = ['Christian Neubauer']
  spec.email         = ['me@christianneubauer.de']

  spec.summary       = 'SSH module for spectre'
  spec.description   = 'Adds SSH access functionality to the spectre framework'
  spec.homepage      = 'https://github.com/cneubauer/spectre-ssh'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.metadata['allowed_push_host'] = 'https://rubygems.org/'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/cneubauer/spectre-ssh'
  spec.metadata['changelog_uri'] = 'https://github.com/cneubauer/spectre-ssh/blob/master/CHANGELOG.md'

  spec.files        += Dir.glob('lib/**/*')

  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'openssl', '~> 2.2.0'
  spec.add_runtime_dependency 'net-ssh', '~> 6.1.0'
  spec.add_runtime_dependency 'spectre-core', '>= 1.8.4'
end
