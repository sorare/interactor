require "English"

Gem::Specification.new do |spec|
  spec.name = "interactor_with_steroids"
  spec.version = "1.1.1"

  spec.author = "Collective Idea/Sorare Team"
  spec.email = "hello@sorare.com"
  spec.description = "Interactor provides a common interface for performing complex user interactions."
  spec.summary = "Simple interactor implementation"
  spec.homepage = "https://github.com/sorare/interactor"
  spec.license = "MIT"

  spec.files = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.test_files = spec.files.grep(/^spec/)

  spec.add_dependency "activesupport"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
