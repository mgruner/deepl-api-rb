# deepl-api-rb

This repository contains a [Ruby](https://www.ruby-lang.org/) implementation of the [DeepL REST API](https://www.deepl.com/docs-api/).

## Contents

- A [Ruby package](https://mgruner.github.io/deepl-api-rb-docs/DeeplAPI/DeepL.html) for easy integration into Ruby applications.
- The `deepl` [unix-style commandline application](https://mgruner.github.io/deepl-api-rb-docs/lib/deepl_api/deepl_md.html) for integration into existing toolchains without any programming effort.
- Unit and integration tests.

Please refer to the linked documentation for instructions on how to get started with the API and/or the CLI tool.

## Features

- Query your account usage & limits information.
- Fetch the list of available source and target languages provided by DeepL.
- Translate text.

## Not Implemented

- Support for the [(beta) document translation endpoint](https://www.deepl.com/docs-api/translating-documents/).
- Support for the [XML handling flags](https://www.deepl.com/docs-api/translating-text/) in the translation endpoint.

## See Also

There are comparable implementations for [Rust](https://github.com/mgruner/deepl-api-rs) and [Python](https://github.com/mgruner/deepl-api-py).
