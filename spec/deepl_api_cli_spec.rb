# frozen_string_literal: true

require "open3"
require "rspec/temp_dir"

RSpec.describe "deepl help" do
  it "shows usage information" do
    stdout, _stderr, status = Open3.capture3("deepl --help")
    expect(stdout).to include "Commands:"
    expect(status.exitstatus).to eq 0
  end
end

RSpec.describe "deepl authentication" do
  it "works with a valid (external) API key" do
    _stdout, _stderr, status = Open3.capture3("deepl usage-information")
    expect(status.exitstatus).to eq 0
  end

  it "fails with a missing (external) API key" do
    _stdout, stderr, status = Open3.capture3({ "DEEPL_API_KEY" => nil }, "deepl usage-information")
    expect(status.exitstatus).to eq 1
    expect(stderr).to eq "Error: No DEEPL_API_KEY found. Please provide your API key in this environment variable.\n"
  end

  it "fails with a wrong (external) API key" do
    _stdout, stderr, status = Open3.capture3({ "DEEPL_API_KEY" => "wrong_key" }, "deepl usage-information")
    expect(status.exitstatus).to eq 1
    expect(stderr).to eq "Error: Authorization failed, is your API key correct?\n"
  end
end

RSpec.describe "deepl usage-information" do
  it "works" do
    stdout, _stderr, status = Open3.capture3("deepl usage-information")
    expect(status.exitstatus).to eq 0
    expect(stdout).to include "Available characters per billing period:"
  end
end

RSpec.describe "deepl languages" do
  it "works" do
    stdout, _stderr, status = Open3.capture3("deepl languages")
    expect(status.exitstatus).to eq 0
    expect(stdout).to include "RU    (Russian)"
  end
end

# rubocop:disable Metrics/BlockLength
RSpec.describe "deepl translate" do
  # create temp dir and cd to temp dir
  include_context "within temp dir"

  it "fails on missing language" do
    _stdout, stderr, status = Open3.capture3("deepl translate")
    expect(status.exitstatus).to eq 1
    expect(stderr).to eq "No value provided for required options '--target-language'\n"
  end

  it "works with minimal arguments" do
    stdout, _stderr, status = Open3.capture3(
      "deepl translate --source-language EN --target-language DE",
      stdin_data: "Please go home."
    )
    expect(status.exitstatus).to eq 0
    expect(stdout).to eq "Bitte gehen Sie nach Hause.\n"
  end

  it "fails with wrong target language" do
    _stdout, stderr, status = Open3.capture3(
      "deepl translate --source-language EN --target-language FALSE",
      stdin_data: "Please go home."
    )
    expect(status.exitstatus).to eq 1
    expect(stderr).to eq "Error: An error occurred while communicating with the DeepL server: " \
                         "'Value for 'target_lang' not supported.'.\n"
  end

  it "can read from and write to files" do
    File.write("input_file.txt", "Please go home.")
    _stdout, _stderr, status = Open3.capture3(
      "deepl translate --source-language EN --target-language DE" \
      " --input-file input_file.txt --output_file output_file.txt"
    )
    expect(status.exitstatus).to eq 0
    expect(File.read("output_file.txt")).to eq "Bitte gehen Sie nach Hause."
  end

  it "fails on missing input file" do
    _stdout, stderr, status = Open3.capture3(
      "deepl translate --source-language EN --target-language DE " \
      "--input-file missing_input_file.txt --output_file output_file.txt"
    )
    expect(status.exitstatus).to eq 1
    expect(stderr).to eq "Error: No such file or directory @ rb_sysopen - missing_input_file.txt\n"
  end

  it "fails on unavailable output file" do
    File.write("input_file.txt", "Please go home.")
    _stdout, stderr, status = Open3.capture3(
      "deepl translate --source-language EN --target-language DE " \
      "--input-file input_file.txt --output_file nonexisting/file/path"
    )
    expect(status.exitstatus).to eq 1
    expect(stderr).to eq "Error: No such file or directory @ rb_sysopen - nonexisting/file/path\n"
  end
end
# rubocop:enable Metrics/BlockLength
