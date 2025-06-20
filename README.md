# 🔥 Glaser

> *AI-powered code review with the wit of Nikki Glaser*

**Glaser** is an AI-powered code review and commentary tool that uses Shopify's [Roast](https://github.com/Shopify/roast) workflow engine to "roast" your codebase — not just by finding bugs and inefficiencies, but by delivering those insights with snark, wit, and a comedic edge inspired by Nikki Glaser.

## Features

- 🧠 **Multi-Agent Analysis**: Four specialized AI agents analyze different aspects of your code
- 📝 **Documentation Agent**: Reviews README files, docs, and inline comments
- 🧱 **Code Quality Agent**: Finds dead code, complexity issues, and anti-patterns  
- 📦 **Dependency Agent**: Analyzes package vulnerabilities and bloat
- 🕵️ **Bug Hunter Agent**: Detects logic errors and security flaws
- 🎭 **Roast Mode**: Get feedback with Nikki Glaser-style humor
- 😐 **Serious Mode**: Skip the jokes for pure technical analysis
- 🐙 **GitHub Integration**: Analyze remote repositories directly

## Installation

### Prerequisites

- Ruby 3.2.2 or higher
- OpenAI API key or Anthropic API key

### Setup

1. Clone and install:
```bash
git clone <your-repo-url>
cd glaser
bundle install
```

2. Configure your API keys:
```bash
cp .env.example .env
# Edit .env with your API keys
```

3. Make CLI executable:
```bash
chmod +x exe/glaser
```

## Usage

### Basic Usage

```bash
# Analyze a local codebase
./exe/glaser ./my-project

# Analyze a GitHub repository  
./exe/glaser https://github.com/user/repo

# Serious mode (no humor)
./exe/glaser ./my-project --serious

# Custom output file
./exe/glaser ./my-project --output my-roast.md

# Show help
./exe/glaser --help

# Show version
./exe/glaser version
```

### Configuration

Create a `.env` file with your API configuration:

```env
# Required: OpenAI or Anthropic API key
OPENAI_API_KEY=your_openai_api_key_here
ANTHROPIC_API_KEY=your_anthropic_api_key_here

# Optional: GitHub token for private repos
GITHUB_TOKEN=your_github_token_here

# Optional: API provider (openai or anthropic)
GLASER_API_PROVIDER=openai

# Optional: Model selection
GLASER_MODEL=gpt-4o-mini
```

## How It Works

1. **Repository Analysis**: Glaser scans your codebase and chunks it by file type and size
2. **Multi-Agent Workflow**: Four specialized agents analyze different aspects:
   - Documentation quality and completeness
   - Code quality issues and anti-patterns
   - Dependency management and security
   - Bug detection and security vulnerabilities
3. **Report Generation**: Results are compiled into a comprehensive Markdown report with both technical insights and comedic commentary

## Sample Output

```markdown
# 🔥 Glaser Code Roast Report

## 📝 Documentation Agent
"This README is more confused than me trying to understand cryptocurrency. 
It says 'easy setup' but then lists 47 prerequisites."

## 🧱 Code Quality Agent  
"This function is so long it should qualify for severance pay."

## 📦 Dependency Agent
"You're still using jQuery 1.0? That's older than my first headshot!"
```

## Development

### Running Tests

```bash
bundle exec rspec
```

### Code Style

```bash
bundle exec rubocop
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Run the test suite
6. Submit a pull request

## Architecture

- **CLI Interface**: Thor-based command line interface
- **Workflow Engine**: Powered by Shopify's Roast framework
- **Multi-Agent System**: Four specialized analysis agents
- **Repository Handling**: Support for local paths and GitHub URLs
- **Configurable Output**: Markdown reports with customizable tone

## License

MIT License - see LICENSE file for details.

## Credits

- Inspired by Nikki Glaser's comedic style
- Powered by [Shopify's Roast](https://github.com/Shopify/roast) workflow engine
- Built with Ruby and AI magic ✨