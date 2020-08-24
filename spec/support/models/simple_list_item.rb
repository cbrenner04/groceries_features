# frozen_string_literal: true

module Models
  # an item on a simple list
  class SimpleListItem
    attr_accessor :content
    attr_reader :id, :user_id, :list_id, :completed, :refreshed, :category

    def initialize(user_id:, list_id:, completed: false, category: nil, refreshed: false, create_item: true)
      @user_id = user_id
      @list_id = list_id
      @content = SecureRandom.hex(16)
      @completed = completed
      @refreshed = refreshed
      @category = category
      @id = create if create_item
    end

    def pretty_title
      content
    end

    private

    def create
      DB[:simple_list_items].insert(user_id: user_id, list_id: list_id, content: content,
                                    completed: completed, refreshed: refreshed, created_at: Time.now,
                                    updated_at: Time.now, category: category)
    end
  end
end
