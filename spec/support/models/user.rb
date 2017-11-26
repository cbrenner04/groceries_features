# frozen_string_literal: true

require 'bcrypt'

module Models
  # a user of the application
  class User
    attr_reader :id, :email, :password

    def initialize(create: true)
      @email = "test#{Time.now.to_i}@example.com"
      @password = SecureRandom.hex(32)
      @id = create_user if create
    end

    private

    def create_user
      DB[:users].insert(
        email: email, encrypted_password: BCrypt::Password.create(password),
        is_test_account: true, created_at: Time.now, updated_at: Time.now
      )
    end
  end
end
