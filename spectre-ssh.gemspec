# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'spectre-ssh'
  spec.version       = '2.0.0'
  spec.authors       = ['Christian Neubauer']
  spec.email         = ['christian.neubauer@ionos.com']

  spec.summary       = 'Standalone SSH wrapper compatible with spectre'
  spec.description   = 'A SSH wrapper for nice readability. Is compatible with spectre-core.'
  spec.homepage      = 'https://github.com/ionos-spectre/spectre-ssh'
  spec.license       = 'GPL-3.0-or-later'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.1.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/ionos-spectre/spectre-ssh'
  spec.metadata['changelog_uri'] = 'https://github.com/ionos-spectre/spectre-ssh/blob/master/CHANGELOG.md'

  spec.files = Dir.glob('lib/**/*')
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'bcrypt_pbkdf', '~> 1.1.0'
  spec.add_runtime_dependency 'ed25519', '~> 1.3.0'
  spec.add_runtime_dependency 'net-ssh', '~> 7.2.0'
  spec.add_runtime_dependency 'openssl', '~> 3.2.0'
end
