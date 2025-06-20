require 'thor'
require 'colorize'
require_relative 'analyzer'

module Glaser
  class CLI < Thor
    desc 'roast PATH_OR_URL', 'Roast a codebase with AI-powered analysis and witty commentary'
    long_desc <<~DESC
      Analyzes a local codebase path or GitHub repository URL using Shopify's Roast workflow engine.
      
      Examples:
        glaser ./my-project
        glaser https://github.com/user/repo
        glaser /path/to/codebase --serious
        glaser ./code --output my-report.md
    DESC
    option :serious, type: :boolean, default: false, desc: 'Skip the humor and provide raw technical analysis'
    option :output, type: :string, desc: 'Output file for the report (default: timestamped filename)'
    def roast(path_or_url = nil)
      # If no argument provided, show help
      if path_or_url.nil?
        puts help('roast')
        return
      end

      puts "🔥 Glaser is warming up to roast your code...".colorize(:red)
      
      analyzer = Analyzer.new(
        target: path_or_url,
        serious_mode: options[:serious],
        output_file: options[:output]
      )
      
      analyzer.analyze
    rescue StandardError => e
      puts "💥 Error: #{e.message}".colorize(:red)
      exit 1
    end

    desc 'version', 'Show version'
    def version
      puts "Glaser v#{VERSION}"
    end

    # Make roast the default command
    default_task :roast
    
    # Override to handle direct path arguments
    def self.start(given_args = ARGV, config = {})
      # If first arg looks like a path or URL and isn't a known command
      if given_args.any? && !%w[help version].include?(given_args.first) && 
         (File.exist?(given_args.first.to_s) || given_args.first.to_s.match?(/^https?:\/\//))
        given_args.unshift('roast')
      end
      super(given_args, config)
    end
  end
end