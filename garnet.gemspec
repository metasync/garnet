# frozen_string_literal: true

require_relative 'lib/garnet/version'

Gem::Specification.new do |spec|
  spec.name = 'garnet'
  spec.version = Garnet::VERSION.dup
  spec.authors = ['Chi Man Lei']
  spec.email = ['chimanlei@gmail.com']

  spec.summary = 'Actor-based service object framework'
  spec.description = 'Actor-based service object framework'
  spec.homepage = 'https://github.com/metasync/garnet'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/metasync/garnet'
  spec.metadata['changelog_uri'] = 'https://github.com/metasync/garnet/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  # spec.files = Dir.chdir(__dir__) do
  #   `git ls-files -z`.split("\x0").reject do |f|
  #     (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
  #   end
  # end
  spec.files = Dir['CHANGELOG.md', 'LICENSE.text', 'README.md', 'garnet.gemspec', 'lib/**/*']
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'dotenv', '~> 2.8'
  spec.add_runtime_dependency 'dry-logger', '~> 1.0'
  spec.add_runtime_dependency 'dry-monads', '~> 1.6'
  spec.add_runtime_dependency 'dry-system', '~> 1.0'
  spec.add_runtime_dependency 'dry-types', '~> 1.7'
  spec.add_runtime_dependency 'dry-validation', '~> 1.10'
  spec.add_runtime_dependency 'rom', '~> 5.3'
  spec.add_runtime_dependency 'rom-sql', '~> 3.6'
  spec.add_runtime_dependency 'ulid', '~> 1.4'
end
