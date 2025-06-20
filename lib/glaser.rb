require_relative 'glaser/version'
require_relative 'glaser/config'
require_relative 'glaser/cli'
require_relative 'glaser/analyzer'
require_relative 'glaser/github_handler'
require_relative 'glaser/chunker'

module Glaser
  class Error < StandardError; end
end