# frozen_string_literal: true

require_relative "lib/deepl_api/version"

Gem::Specification.new do |spec|
  spec.name          = "deepl_api"
  spec.version       = DeeplAPI::VERSION
  spec.authors       = ["Martin Gruner"]
  spec.email         = ["mg.pub@gmx.net"]

  spec.summary       = "Bindings and a commandline tool for the DeepL REST API"
  spec.description   = "Bindings and a commandline tool for the DeepL REST API (https://www.deepl.com/docs-api/)"
  spec.homepage      = "https://github.com/mgruner/deepl-api-rb"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/mgruner/deepl-api-rb"
  spec.metadata["changelog_uri"] = "https://github.com/mgruner/deepl-api-rb/blob/next/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "ruby-enum", "~> 0.9"
  spec.add_dependency "thor", "~> 1.1"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
