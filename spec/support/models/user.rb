# frozen_string_literal: true

require "bcrypt"

module Models
  # a user of the application
  class User
    TEMPLATE_DEFINITIONS = {
      "grocery list template" => [
        { label: "product", data_type: "free_text", position: 1 },
        { label: "quantity", data_type: "free_text", position: 2 },
        { label: "category", data_type: "free_text", position: 3 }
      ],
      "book list template" => [
        { label: "author", data_type: "free_text", position: 1 },
        { label: "title", data_type: "free_text", position: 2 },
        { label: "number_in_series", data_type: "number", position: 3 },
        { label: "read", data_type: "boolean", position: 4 },
        { label: "category", data_type: "free_text", position: 5 }
      ],
      "music list template" => [
        { label: "title", data_type: "free_text", position: 1 },
        { label: "artist", data_type: "free_text", position: 2 },
        { label: "album", data_type: "free_text", position: 3 },
        { label: "category", data_type: "free_text", position: 4 }
      ],
      "to do list template" => [
        { label: "task", data_type: "free_text", position: 1 },
        { label: "assignee", data_type: "free_text", position: 2 },
        { label: "due_by", data_type: "date_time", position: 3 },
        { label: "category", data_type: "free_text", position: 4 }
      ],
      "simple list with category template" => [
        { label: "content", data_type: "free_text", position: 1 },
        { label: "category", data_type: "free_text", position: 2 }
      ]
    }.freeze

    attr_reader :id, :email, :password

    def initialize(create_user: true)
      @email = "test#{SecureRandom.hex(16)}@example.com"
      @password = SecureRandom.hex(32)
      @id = create if create_user
    end

    private

    def create
      user_id = DB[:users].insert(email:, encrypted_password: BCrypt::Password.create(password),
                                  is_test_account: true, created_at: Time.now, updated_at: Time.now, uid: email)
      create_default_configurations(user_id)
      user_id
    end

    def create_default_configurations(user_id)
      TEMPLATE_DEFINITIONS.each do |template_name, fields|
        config_id = DB[:list_item_configurations].insert(
          name: template_name, user_id: user_id, created_at: Time.now, updated_at: Time.now
        )
        fields.each do |field|
          DB[:list_item_field_configurations].insert(
            label: field[:label], data_type: field[:data_type], position: field[:position],
            list_item_configuration_id: config_id, created_at: Time.now, updated_at: Time.now
          )
        end
      end
    end
  end
end
