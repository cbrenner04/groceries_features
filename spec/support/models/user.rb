# frozen_string_literal: true

require 'bcrypt'

module Models
  # a user of the application
  class User
    attr_reader :email, :password

    def initialize
      @email = "test#{Time.now.to_i}@example.com"
      @password = SecureRandom.hex(32)
      create_user
    end

    private

    def create_user
      DB.exec("INSERT INTO users (email, encrypted_password, is_test_account,
                                  created_at, updated_at)
                 VALUES ('#{email}', '#{BCrypt::Password.create(password)}',
                         'true', now(), now())")
    end
  end
end
