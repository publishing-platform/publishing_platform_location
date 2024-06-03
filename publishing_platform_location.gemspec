# frozen_string_literal: true

require_relative "lib/publishing_platform_location/version"

Gem::Specification.new do |spec|
  spec.name = "publishing_platform_location"
  spec.version = PublishingPlatformLocation::VERSION
  spec.authors = ["Publishing Platform"]

  spec.summary = "Generates URLs for publishing platform services based on environment."
  spec.description = "Generates URLs for publishing platform services based on environment."
  spec.license = "MIT"  
  spec.required_ruby_version = ">= 3.0"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end

  spec.require_paths = ["lib"]

  spec.add_development_dependency "publishing_platform_rubocop"
end
