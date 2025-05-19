# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'spectre-ssh'
  spec.version       = '2.1.0'
  spec.authors       = ['Christian Neubauer']
  spec.email         = ['christian.neubauer@ionos.com']

  spec.summary       = 'Standalone SSH wrapper compatible with spectre'
  spec.description   = 'A SSH wrapper for nice readability. Is compatible with spectre-core.'
  spec.homepage      = 'https://github.com/ionos-spectre/spectre-ssh'
  spec.license       = 'GPL-3.0-or-later'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/ionos-spectre/spectre-ssh'
  spec.metadata['changelog_uri'] = 'https://github.com/ionos-spectre/spectre-ssh/blob/master/CHANGELOG.md'

  spec.files = Dir.glob('lib/**/*')
  spec.require_paths = ['lib']

  spec.add_dependency 'bcrypt_pbkdf'
  spec.add_dependency 'ed25519'
  spec.add_dependency 'net-ssh'
  spec.add_dependency 'openssl'
  spec.add_dependency 'stringio'
end
