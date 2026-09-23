# frozen_string_literal: true

module UserHub
  class Error < StandardError; end

  # Raised when input fails validation. #errors holds every message.
  class ValidationError < Error
    attr_reader :errors

    def initialize(errors)
      @errors = Array(errors)
      super(@errors.join("\n"))
    end
  end

  class NotFoundError < Error; end
  class DuplicateError < Error; end
  class LimitError < Error; end
end
