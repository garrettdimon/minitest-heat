# frozen_string_literal: true

require_relative 'lib/minitest/heat/version'

Gem::Specification.new do |spec|
  spec.name          = 'minitest-heat'
  spec.version       = Minitest::Heat::VERSION
  spec.authors       = ['Garrett Dimon']
  spec.email         = ['email@garrettdimon.com']

  spec.summary       = 'Presents test results in a visual manner to guide you to where to look first.'
  spec.description   = 'Presents test results in a visual manner to guide you to where to look first.'
  spec.homepage      = 'https://github.com/garrettdimon/minitest-heat'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.9')

  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/garrettdimon/minitest-heat'
  spec.metadata['changelog_uri'] = 'https://github.com/garrettdimon/minitest-heat/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'minitest'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'simplecov'
end
