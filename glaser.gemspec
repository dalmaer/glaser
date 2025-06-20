Gem::Specification.new do |spec|
  spec.name        = 'glaser'
  spec.version     = '0.1.0'
  spec.authors     = ['Glaser Team']
  spec.email       = ['team@glaser.dev']

  spec.summary     = 'AI-powered code review tool with snark'
  spec.description = 'Glaser uses Shopify\'s Roast workflow engine to analyze and roast your codebase with wit and technical insights'
  spec.homepage    = 'https://github.com/user/glaser'
  spec.license     = 'MIT'

  spec.required_ruby_version = '>= 3.2.0'

  spec.files = Dir.glob('{lib,exe,workflows}/**/*') + %w[README.md LICENSE Gemfile glaser.gemspec]
  spec.bindir = 'exe'
  spec.executables = ['glaser']
  spec.require_paths = ['lib']

  spec.add_dependency 'roast-ai', '~> 0.1'
  spec.add_dependency 'thor', '~> 1.2'
  spec.add_dependency 'octokit', '~> 6.0'
  spec.add_dependency 'git', '~> 1.18'
  spec.add_dependency 'colorize', '~> 0.8'

  spec.add_development_dependency 'rspec', '~> 3.12'
  spec.add_development_dependency 'rubocop', '~> 1.56'
  spec.add_development_dependency 'pry', '~> 0.14'
end