# frozen_string_literal: true

module UserHub
  # Every method returns an Array of error messages (empty when input is valid).
  # Use Validator.raise_if_invalid(errors) to turn them into a ValidationError.
  module Validator
    EMAIL_PATTERN         = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/
    MIN_USERNAME_LENGTH   = 3
    MIN_PASSWORD_LENGTH   = 6
    MAX_ATTACHMENTS       = 5

    module_function

    # password: pass nil to skip the password check (e.g. profile updates
    # that do not change the password).
    def user(username:, email:, password: nil)
      errors = []
      errors << "Username must be at least #{MIN_USERNAME_LENGTH} characters." if username.to_s.strip.length < MIN_USERNAME_LENGTH
      errors << 'Email address is not valid.' unless email.to_s.strip.match?(EMAIL_PATTERN)
      if !password.nil? && password.to_s.length < MIN_PASSWORD_LENGTH
        errors << "Password must be at least #{MIN_PASSWORD_LENGTH} characters."
      end
      errors
    end

    def address(street:, city:, state:, zip_code:)
      errors = []
      { 'Street' => street, 'City' => city, 'State' => state, 'Zip code' => zip_code }.each do |label, value|
        errors << "#{label} is required." if value.to_s.strip.empty?
      end
      errors
    end

    def post(title:, content:)
      errors = []
      errors << 'Post title is required.' if title.to_s.strip.empty?
      errors << 'Post content is required.' if content.to_s.strip.empty?
      errors
    end

    def attachment(file_name:, file_type:, file_size:)
      errors = []
      errors << 'Attachment file name is required.' if file_name.to_s.strip.empty?
      errors << 'Attachment file type is required.' if file_type.to_s.strip.empty?
      size = Float(file_size, exception: false)
      errors << 'Attachment file size must be greater than 0.' if size.nil? || size <= 0
      errors
    end

    def attachment_limit(post)
      return [] if post.attachments.size < MAX_ATTACHMENTS

      ["A post can have at most #{MAX_ATTACHMENTS} attachments."]
    end

    def raise_if_invalid(errors)
      raise ValidationError, errors unless errors.empty?
    end
  end
end
