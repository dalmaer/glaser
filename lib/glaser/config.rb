require 'dotenv/load'

module Glaser
  class Config
    class << self
      def openai_api_key
        ENV['OPENAI_API_KEY'] || raise(Error, 'OPENAI_API_KEY environment variable not set')
      end

      def anthropic_api_key
        ENV['ANTHROPIC_API_KEY']
      end

      def github_token
        ENV['GITHUB_TOKEN']
      end

      def api_provider
        ENV['GLASER_API_PROVIDER'] || 'openai'
      end

      def model_name
        case api_provider.downcase
        when 'openai'
          ENV['GLASER_MODEL'] || 'gpt-4o-mini'
        when 'anthropic'
          ENV['GLASER_MODEL'] || 'claude-3-haiku-20240307'
        else
          raise Error, "Unsupported API provider: #{api_provider}"
        end
      end

      def roast_config
        {
          model: model_name,
          api_key: primary_api_key,
          provider: api_provider
        }
      end

      private

      def primary_api_key
        case api_provider.downcase
        when 'openai'
          openai_api_key
        when 'anthropic'
          anthropic_api_key || raise(Error, 'ANTHROPIC_API_KEY environment variable not set')
        else
          raise Error, "No API key configured for provider: #{api_provider}"
        end
      end
    end
  end
end