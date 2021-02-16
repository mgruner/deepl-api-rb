# frozen_string_literal: true

require "thor"
require_relative "../deepl_api"

module DeeplAPI
  # This class implements the `deepl` command line utility.
  class CLI < Thor
    def self.exit_on_failure?
      # Exit in case of missing arguments etc.
      true
    end

    desc "usage-information", "Fetch account usage information"
    def usage_information
      usage = instance.usage_information
      puts("Available characters per billing period: #{usage.character_limit}")
      puts("Characters already translated in the current billing period: #{usage.character_count}")
    end

    desc "languages", "Fetch information about available source and target languages"
    def languages
      deepl = instance
      source_langs = deepl.source_languages
      target_langs = deepl.target_languages

      puts("DeepL can translate from the following source languages:")
      source_langs.each { |language, name| puts("  #{language.ljust(5)} (#{name})") }
      puts
      puts("DeepL can translate to the following target languages:")
      target_langs.each { |language, name| puts("  #{language.ljust(5)} (#{name})") }
    end

    # rubocop:disable Metrics/MethodLength
    option "source-language", desc: "The source language to use", banner: "DE"
    option "target-language", desc: "The target language to use", banner: "EN", required: true
    option "input-file", desc: "Read from this file rather than STDIN", banner: "path/to/file"
    option "output-file", desc: "Write to this file rather than STDOUT", banner: "path/to/file"
    option "preserve-formatting", desc: "Preserve source text formatting", type: :boolean
    option "formality-more", desc: "Translate more formally", type: :boolean
    option "formality-less", desc: "Translate less formally", type: :boolean
    desc "translate", "Translate text"
    def translate
      formality = DeeplAPI::Formality::DEFAULT
      formality = DeeplAPI::Formality::LESS if options["formality-less"]
      formality = DeeplAPI::Formality::MORE if options["formality-more"]

      text = if options["input-file"]
               File.read(options["input-file"])
             else
               $stdin.read
             end

      result = instance.translate(
        source_language: options["source-language"],
        target_language: options["target-language"],
        preserve_formatting: options["preserve-formatting"],
        formality: formality,
        texts: [text]
      )

      text = result.map { |entry| entry["text"] }.join

      if options["output-file"]
        File.write(options["output-file"], text)
      else
        puts text
      end
    end
    # rubocop:enable Metrics/MethodLength

    private

    def instance
      api_key = ENV["DEEPL_API_KEY"].to_s
      if api_key.empty?
        raise StandardError, "No DEEPL_API_KEY found. Please provide your API key in this environment variable."
      end

      DeeplAPI::DeepL.new(api_key: ENV["DEEPL_API_KEY"])
    end
  end
end
