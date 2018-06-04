# frozen_string_literal: true

module Models
  # an item on a grocery list
  class GroceryListItem
    attr_reader :id, :user_id, :grocery_list_id, :name, :quantity, :purchased,
                :refreshed
    attr_writer :name

    def initialize(user_id:, grocery_list_id:, purchased: false,
                   refreshed: false, create_item: true)
      @user_id = user_id
      @grocery_list_id = grocery_list_id
      @name = SecureRandom.hex(16)
      @quantity = "#{rand(10)} #{SecureRandom.hex(8)}"
      @purchased = purchased
      @refreshed = refreshed
      @id = create if create_item
    end

    def pretty_title
      "#{quantity} #{name}"
    end

    private

    def create
      DB[:grocery_list_items].insert(
        user_id: user_id, grocery_list_id: grocery_list_id, name: name,
        quantity: quantity, purchased: purchased, refreshed: refreshed,
        created_at: Time.now, updated_at: Time.now
      )
    end
  end
end
