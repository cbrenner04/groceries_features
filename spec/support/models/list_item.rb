# frozen_string_literal: true

module Models
  # an item on a list
  class ListItem
    attr_accessor :archived_at, :refreshed, :completed, :user_id, :list_id
    attr_reader :id, :created_at, :updated_at

    def initialize(user_id:, list_id:, archived_at: nil, refreshed: false, completed: false, create_item: true)
      @user_id = user_id
      @list_id = list_id
      @archived_at = archived_at
      @refreshed = refreshed
      @completed = completed
      @id = create if create_item
    end

    private

    def create
      DB[:list_items].insert(user_id:, list_id:, archived_at:, refreshed:, completed:,
                             created_at: Time.now, updated_at: Time.now)
    end
  end
end
