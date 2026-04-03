# frozen_string_literal: true

require_relative "lib/publishing_platform_location/version"

Gem::Specification.new do |spec|
  spec.name = "publishing_platform_location"
  spec.version = PublishingPlatformLocation::VERSION
  spec.authors = ["Publishing Platform"]

  spec.summary = "Generates URLs for publishing platform services based on environment."
  spec.description = "Generates URLs for publishing platform services based on environment."
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.files = Dir.glob("lib/**/*") + %w[LICENSE README.md]

  spec.require_paths = %w[lib]

  spec.add_development_dependency "climate_control", "~> 1.2"
  spec.add_development_dependency "publishing_platform_rubocop", "~> 0.2"
  spec.add_development_dependency "simplecov", "~> 0.22"
end
