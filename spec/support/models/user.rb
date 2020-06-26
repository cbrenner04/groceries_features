# frozen_string_literal: true

require 'bcrypt'

module Models
  # a user of the application
  class User
    attr_reader :id, :email, :password

    def initialize(create_user: true)
      @email = "test#{SecureRandom.hex(16)}@example.com"
      @password = SecureRandom.hex(32)
      @id = create if create_user
    end

    private

    def create
      DB[:users].insert(
        email: email, encrypted_password: BCrypt::Password.create(password),
        is_test_account: true, created_at: Time.now, updated_at: Time.now,
        uid: email
      )
    end
  end
end
