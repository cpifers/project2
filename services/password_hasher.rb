# frozen_string_literal: true

require 'openssl'
require 'securerandom'

module UserHub
  # Salted, iterated password hashing using only the standard library
  # (PBKDF2-HMAC-SHA256). Plain-text passwords are never stored.
  # If you prefer the bcrypt gem, only #digest and #verify need to change.
  module PasswordHasher
    SCHEME     = 'pbkdf2-sha256'
    ITERATIONS = 120_000
    KEY_LENGTH = 32

    def self.digest(password)
      salt = SecureRandom.random_bytes(16)
      hash = OpenSSL::PKCS5.pbkdf2_hmac(password.to_s, salt, ITERATIONS, KEY_LENGTH, 'sha256')
      [SCHEME, ITERATIONS, salt.unpack1('H*'), hash.unpack1('H*')].join('$')
    end

    def self.verify(password, stored_digest)
      scheme, iterations, salt_hex, hash_hex = stored_digest.to_s.split('$')
      return false unless scheme == SCHEME

      salt     = [salt_hex].pack('H*')
      expected = [hash_hex].pack('H*')
      actual   = OpenSSL::PKCS5.pbkdf2_hmac(password.to_s, salt, iterations.to_i, KEY_LENGTH, 'sha256')
      OpenSSL.fixed_length_secure_compare(actual, expected)
    rescue ArgumentError
      false
    end
  end
end
