# frozen_string_literal: true

module Models
  # a user of the application
  class BookListItem
    attr_reader :id, :user_id, :book_list_id, :author, :title, :purchased, :read

    def initialize(user_id:, book_list_id:, purchased: false, read: false,
                   create_item: true)
      @user_id = user_id
      @book_list_id = book_list_id
      @author = SecureRandom.hex(16)
      @title = SecureRandom.hex(16)
      @purchased = purchased
      @read = read
      @id = create if create_item
    end

    def create
      DB[:book_list_items].insert(
        user_id: user_id, book_list_id: book_list_id, author: author,
        title: title, purchased: purchased, read: read, created_at: Time.now,
        updated_at: Time.now
      )
    end
  end
end
