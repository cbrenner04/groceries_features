# frozen_string_literal: true

module Models
  # an item on a book list
  class BookListItem
    attr_reader :id, :user_id, :book_list_id, :author, :title, :purchased,
                :read, :number_in_series, :category
    attr_writer :title

    def initialize(user_id:, book_list_id:, purchased: false, read: false,
                   create_item: true)
      @user_id = user_id
      @book_list_id = book_list_id
      @author = SecureRandom.hex(16)
      @title = SecureRandom.hex(16)
      @purchased = purchased
      @read = read
      @number_in_series = 1
      @category = SecureRandom.hex(16)
      @id = create if create_item
    end

    def pretty_title
      "\"#{title}\" #{author}"
    end

    private

    def create
      DB[:book_list_items].insert(
        user_id: user_id, book_list_id: book_list_id, author: author,
        title: title, purchased: purchased, read: read,
        number_in_series: number_in_series, created_at: Time.now,
        updated_at: Time.now
      )
    end
  end
end
