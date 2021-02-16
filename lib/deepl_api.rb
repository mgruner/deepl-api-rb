# frozen_string_literal: true

require "net/http"
require "json"
require "ruby-enum"
require_relative "deepl_api/version"
require_relative "deepl_api/errors"

# Provides a lightweight wrapper for the DeepL Pro REST API.
#
# This gem contains both the [backend API](DeeplAPI/DeepL.html) and the
# [deepl command line utility](lib/deepl_api/deepl_md.html).

## Requirements
#
# You need to have a valid [DeepL Pro Developer](https://www.deepl.com/pro#developer) account
# with an associated API key. This key must be made available to the application, e. g. via
# environment variable:
#
# ```bash
# export DEEPL_API_KEY=YOUR_KEY
# ```
#
# ## Example
#
# ```text
# require "deepl_api"
#
# deepl = DeeplAPI::DeepL.new( api_key: ENV["DEEPL_API_KEY"] )
# usage = deepl.usage_information()
# => #<DeeplAPI::UsageInformation:0x00007fcbc588cc08 @character_limit=250000, @character_count=1450>
#
# translation = deepl.translate( source_language: "DE", target_language: "EN-US", texts: ["ja"] )
# => [{"detected_source_language"=>"DE", "text"=>"yes"}]
# ```
#
# ## See Also
#
# The main API functions are documented in the DeepL class.

module DeeplAPI
  # The main API entry point representing a DeepL developer account with an associated API key.
  #
  # Use this to create a new DeepL API client instance where multiple function calls can be performed.
  # A valid `api_key` is required.
  #
  # Should you ever need to use more than one DeepL account in our program, then you can create one
  # instance for each account / API key.
  #
  # ##Error Handling
  #
  # These methods may throw exceptions from DeeplAPI::Errors and `Net::HTTP`.
  class DeepL
    # Create an instance by providing a valid API key.
    def initialize(api_key:)
      @api_base_url = "https://api.deepl.com/v2"
      @api_key = api_key.to_s
      return unless @api_key.empty?

      raise DeeplAPI::Errors::DeeplAuthorizationError, "No API key provided."
    end

    # Retrieve information about API usage & limits.
    # This can also be used to verify an API key without consuming translation contingent.
    #
    # Returns a DeeplAPI::UsageInformation object.
    #
    # See also the [vendor documentation](https://www.deepl.com/docs-api/other-functions/monitoring-usage/).
    def usage_information
      data = api_call(url: "/usage")
      UsageInformation.new(
        character_count: data["character_count"],
        character_limit: data["character_limit"]
      )
    end

    # Retrieve all currently available source languages.
    #
    # See also the [vendor documentation](https://www.deepl.com/docs-api/other-functions/listing-supported-languages/).
    #
    # Returns a dictionary like: `{"DE" => "German", ...}`
    def source_languages
      languages(type: "source")
    end

    # Retrieve all currently available target languages.
    #
    # See also the [vendor documentation](https://www.deepl.com/docs-api/other-functions/listing-supported-languages/).
    #
    # Returns a dictionary like: `{"DE" => "German", ...}`
    def target_languages
      languages(type: "target")
    end

    # rubocop:disable Metrics/ParameterLists, Style/KeywordParametersOrder

    # Translate one or more text chunks at once. You can pass in optional
    # translation options if you need non-default behaviour.
    #
    # Please see the parameter documentation and the
    # [vendor documentation](https://www.deepl.com/docs-api/translating-text/) for details.
    #
    # Returns a list of dictionaries for the translated content:
    #
    # ```ruby
    # [
    #   {
    #     "detected_source_language" => "DE",
    #     "text" => "Yes. No.",
    #   },
    #   ...
    # ]
    # ```
    def translate(
      source_language: nil,
      target_language:,
      split_sentences: nil,
      preserve_formatting: true,
      formality: Formality::DEFAULT,
      texts:
    )
      # rubocop:enable Metrics/ParameterLists, Style/KeywordParametersOrder

      payload = {
        target_lang: target_language,
        text: texts
      }

      payload[:source_lang] = source_language unless source_language.nil?
      payload[:split_sentences] = split_sentences unless split_sentences.nil?
      payload[:preserve_formatting] = preserve_formatting unless preserve_formatting.nil?
      payload[:formality] = formality unless formality.nil?

      data = api_call(url: "/translate", payload: payload)

      raise DeeplAPI::Errors::DeeplDeserializationError unless data.include?("translations")

      data["translations"]
    end

    private

    # Private method to perform the actual HTTP calls.
    def api_call(url:, payload: {})
      res = Net::HTTP.post_form(URI(@api_base_url + url), { **payload, auth_key: @api_key })
      return JSON.parse(res.body) if res.instance_of? Net::HTTPOK
      if res.instance_of?(Net::HTTPUnauthorized) || res.instance_of?(Net::HTTPForbidden)
        raise DeeplAPI::Errors::DeeplAuthorizationError, "Authorization failed, is your API key correct?"
      end

      begin
        data = JSON.parse(res.body)
        if data["message"]
          raise DeeplAPI::Errors::DeeplServerError,
                "An error occurred while communicating with the DeepL server: '#{data["message"]}'."
        end
      rescue JSON::ParserError
        raise DeeplAPI::Errors::DeeplServerError, res.code
      end
      raise DeeplAPI::Errors::DeeplServerError, res.code
    end

    # Private method to make API calls for the language lists
    def languages(type:)
      data = api_call(url: "/languages", payload: { type: type })
      raise(DeeplAPI::Errors::DeeplDesearializationError) if !data.length || !data[0].include?("language")

      result = {}
      data.each { |i| result[i["language"]] = i["name"] }
      result
    end
  end

  # Information about API usage & limits for this account.
  class UsageInformation
    # How many characters can be translated per billing period, based on the account settings.
    attr_reader :character_limit
    # How many characters were already translated in the current billing period.
    attr_reader :character_count

    def initialize(character_limit:, character_count:)
      @character_limit = character_limit
      @character_count = character_count
    end
  end

  # Translation option that controls the splitting of sentences before the translation.
  #
  # - `SplitSentences::NONE` - Don't split sentences.
  # - `SplitSentences::PUNCTUATION` - Split on punctiation only.
  # - `SplitSentences::PUNCTUATION_AND_NEWLINES` - Split on punctiation and newlines.
  class SplitSentences
    include Ruby::Enum

    define :NONE, 0
    define :PUNCTUATION, 1
    define :PUNCTUATION_AND_NEWLINES, 2
  end

  # Translation option that controls the desired translation formality
  #
  # - `Formality::LESS` - Translate less formally.
  # - `Formality::DEFAULT` - Default formality.
  # - `Formality::MORE` - Translate more formally.
  class Formality
    include Ruby::Enum

    define :LESS, "less"
    define :DEFAULT, "default"
    define :MORE, "more"
  end
end
