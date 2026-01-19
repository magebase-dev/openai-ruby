Gem::Specification.new do |spec|
  spec.name          = "langmesh-openai"
  spec.version       = "1.0.0"
  spec.authors       = ["langmesh"]
  spec.email         = ["support@langmesh.ai"]

  spec.summary       = "Drop-in replacement for OpenAI Ruby client with telemetry and cost optimization"
  spec.description   = "langmesh-wrapped OpenAI client that works identically to ruby-openai with automatic telemetry and cost optimization"
  spec.homepage      = "https://langmesh.ai"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/langmesh-ai/openai-ruby"
  spec.metadata["changelog_uri"] = "https://github.com/langmesh-ai/openai-ruby/blob/main/CHANGELOG.md"

  spec.files = Dir["lib/**/*", "README.md", "LICENSE"]
  spec.require_paths = ["lib"]

  spec.add_dependency "ruby-openai", "~> 6.0"
  spec.add_dependency "httparty", "~> 0.21"

  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "webmock", "~> 3.18"
end
