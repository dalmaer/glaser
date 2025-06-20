require 'git'
require 'octokit'
require 'tmpdir'
require 'fileutils'

module Glaser
  class GitHubHandler
    def initialize
      @cache_dir = File.join(Dir.home, '.glaser', 'repos')
      FileUtils.mkdir_p(@cache_dir)
    end

    def clone_repo(github_url)
      repo_info = parse_github_url(github_url)
      raise Error, "Invalid GitHub URL: #{github_url}" unless repo_info

      cache_path = File.join(@cache_dir, "#{repo_info[:owner]}_#{repo_info[:repo]}")
      
      if Dir.exist?(cache_path)
        puts "  📁 Using cached repository at #{cache_path}".colorize(:cyan)
        update_cached_repo(cache_path)
      else
        puts "  📥 Cloning #{repo_info[:owner]}/#{repo_info[:repo]}...".colorize(:cyan)
        clone_fresh_repo(github_url, cache_path)
      end

      cache_path
    end

    private

    def parse_github_url(url)
      # Match patterns like:
      # https://github.com/owner/repo
      # https://github.com/owner/repo.git
      # https://github.com/owner/repo/
      match = url.match(%r{github\.com/([^/]+)/([^/]+?)(?:\.git)?/?$})
      return nil unless match

      {
        owner: match[1],
        repo: match[2]
      }
    end

    def clone_fresh_repo(url, destination)
      begin
        Git.clone(url, destination)
      rescue Git::GitExecuteError => e
        raise Error, "Failed to clone repository: #{e.message}"
      end
    end

    def update_cached_repo(path)
      begin
        repo = Git.open(path)
        repo.pull
        puts "  🔄 Updated cached repository".colorize(:cyan)
      rescue Git::GitExecuteError => e
        puts "  ⚠️  Could not update cached repo, using existing version: #{e.message}".colorize(:yellow)
      end
    end
  end
end