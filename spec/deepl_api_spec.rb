# frozen_string_literal: true

RSpec.describe DeeplAPI::VERSION do
  it "has a version number" do
    expect(DeeplAPI::VERSION).not_to be nil
  end
end

RSpec.describe DeeplAPI::DeepL do
  it "requires an API key for instantiation" do
    expect { DeeplAPI::DeepL.new(api_key: nil) }.to raise_error(StandardError)
    expect { DeeplAPI::DeepL.new(api_key: "") }.to raise_error(StandardError)
    expect(DeeplAPI::DeepL.new(api_key: "somekey")).to be_a(DeeplAPI::DeepL)
  end
end

RSpec.describe "DeeplAPI::DeepL.usage_information" do
  it "provides an API for fetching usage information" do
    deepl = DeeplAPI::DeepL.new(api_key: ENV["DEEPL_API_KEY"])
    expect(deepl.usage_information.character_limit).to be > 0
  end
end

RSpec.describe "DeeplAPI::DeepL.source_languages" do
  it "Provides a listing of source languages" do
    deepl = DeeplAPI::DeepL.new(api_key: ENV["DEEPL_API_KEY"])
    expect(deepl.source_languages["DE"]).to eq("German")
  end
end

RSpec.describe "DeeplAPI::DeepL.target_languages" do
  it "Provides a listing of target languages" do
    deepl = DeeplAPI::DeepL.new(api_key: ENV["DEEPL_API_KEY"])
    expect(deepl.target_languages["DE"]).to eq("German")
  end
end

RSpec.describe "DeeplAPI::DeepL.translate errors" do
  it "Cannot translate to wrong language" do
    deepl = DeeplAPI::DeepL.new(api_key: ENV["DEEPL_API_KEY"])
    expect do
      deepl.translate(target_language: "NONEXISTING", texts: ["ja"])
    end.to raise_error(DeeplAPI::Errors::DeeplServerError)
  end

  it "Cannot translate to wrong language" do
    deepl = DeeplAPI::DeepL.new(api_key: ENV["DEEPL_API_KEY"])
    expect do
      deepl.translate(target_language: "NONEXISTING", texts: ["ja"])
    end.to raise_error(DeeplAPI::Errors::DeeplServerError)
  end

  it "Cannot translate with wrong API key" do
    deepl = DeeplAPI::DeepL.new(api_key: "wrong_key")
    expect do
      deepl.translate(target_language: "EN-US", texts: ["ja"])
    end.to raise_error(DeeplAPI::Errors::DeeplAuthorizationError)
  end
end

# rubocop:disable Metrics/BlockLength
RSpec.describe "DeeplAPI::DeepL.translate usage" do
  deepl = DeeplAPI::DeepL.new(api_key: ENV["DEEPL_API_KEY"])

  it "Can translate with various options" do
    tests = [
      {
        args: {
          source_language: "DE",
          target_language: "EN-US",
          texts: ["ja"]
        },
        result: [
          {
            "detected_source_language" => "DE",
            "text" => "yes"
          }
        ]
      },
      {
        args: {
          source_language: "DE",
          target_language: "EN-US",
          preserve_formatting: true,
          texts: ["ja\n nein"]
        },
        result: [
          {
            "detected_source_language" => "DE",
            "text" => "yes\n no"
          }
        ]
      },
      {
        args: {
          source_language: "DE",
          target_language: "EN-US",
          split_sentences: DeeplAPI::SplitSentences::NONE,
          texts: ["Ja. Nein."]
        },
        result: [
          {
            "detected_source_language" => "DE",
            "text" => "Yes. No."
          }
        ]
      },
      {
        args: {
          source_language: "EN",
          target_language: "DE",
          formality: DeeplAPI::Formality::MORE,
          texts: ["Please go home."]
        },
        result: [
          {
            "detected_source_language" => "EN",
            "text" => "Bitte gehen Sie nach Hause."
          }
        ]
      },
      {
        args: {
          source_language: "EN",
          target_language: "DE",
          formality: DeeplAPI::Formality::LESS,
          texts: ["Please go home."]
        },
        result: [
          {
            "detected_source_language" => "EN",
            "text" => "Bitte geh nach Hause."
          }
        ]
      }
    ]

    tests.each do |test|
      expect(deepl.translate(**test[:args])).to eq(test[:result])
    end
  end
end
# rubocop:enable Metrics/BlockLength
