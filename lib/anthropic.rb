require "httparty"

require_relative "anthropic/http"
require_relative "anthropic/client"
require_relative "anthropic/version"

module Anthropic
  class Error < StandardError; end
  class ConfigurationError < Error; end

  class Configuration
    attr_writer :access_token
    attr_accessor :anthropic_version, :api_version, :extra_headers, :organization_id,
                  :request_timeout, :uri_base

    DEFAULT_API_VERSION = "v1".freeze
    DEFAULT_ANTHROPIC_VERSION = "2023-06-01".freeze
    DEFAULT_URI_BASE = "https://api.anthropic.com/".freeze
    DEFAULT_REQUEST_TIMEOUT = 120

    def initialize
      @access_token = nil
      @api_version = DEFAULT_API_VERSION
      @anthropic_version = DEFAULT_ANTHROPIC_VERSION
      @organization_id = nil
      @uri_base = DEFAULT_URI_BASE
      @request_timeout = DEFAULT_REQUEST_TIMEOUT
    end

    def access_token
      return @access_token if @access_token

      error_text = "Anthropic access token missing! See https://github.com/alexrudall/anthropic#usage"
      raise ConfigurationError, error_text
    end
  end

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Anthropic::Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
