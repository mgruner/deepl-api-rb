# frozen_string_literal: true

module DeeplAPI
  # DeepL API exception classes.
  module Errors
    # Base class for exceptions in this module.
    class DeeplBaseError < StandardError
    end

    # Authorization failed.
    class DeeplAuthorizationError < DeeplBaseError
    end

    # Received an error message from the server.
    class DeeplServerError < DeeplBaseError
    end

    # Exception raised when deserialization the server response.
    class DeeplDeserializationError < DeeplBaseError
    end
  end
end
