Gem::Specification.new do |spec|
  spec.name          = 'spectre-ssh'
  spec.version       = '1.2.2'
  spec.authors       = ['Christian Neubauer']
  spec.email         = ['christian.neubauer@ionos.com']

  spec.summary       = 'SSH module for spectre'
  spec.description   = 'Adds SSH access functionality to the spectre framework'
  spec.homepage      = 'https://github.com/ionos-spectre/spectre-ssh'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.0.0')

  #spec.metadata['allowed_push_host'] = 'https://rubygems.org/'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/ionos-spectre/spectre-ssh'
  spec.metadata['changelog_uri'] = 'https://github.com/ionos-spectre/spectre-ssh/blob/master/CHANGELOG.md'

  spec.files        += Dir.glob('lib/**/*')

  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'openssl', '~> 3.2.0'
  spec.add_runtime_dependency 'net-ssh', '~> 7.2.0'
  spec.add_runtime_dependency 'spectre-core', '>= 1.14.6'
  spec.add_runtime_dependency 'ed25519', '~> 1.3.0'
  spec.add_runtime_dependency 'bcrypt_pbkdf', '~> 1.1.0'
end
