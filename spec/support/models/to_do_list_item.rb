# frozen_string_literal: true

module Models
  # an item on a to do list
  class ToDoListItem
    attr_reader :id, :user_id, :to_do_list_id, :name, :assignee_id,
                :due_by, :completed, :refreshed

    def initialize(user_id:, to_do_list_id:, assignee_id: nil, completed: false,
                   refreshed: false, create_item: true)
      @user_id = user_id
      @to_do_list_id = to_do_list_id
      @name = SecureRandom.hex(16)
      @assignee_id = assignee_id
      @due_by = Date.today + rand(180)
      @completed = completed
      @refreshed = refreshed
      @id = create if create_item
    end

    private

    def create
      DB[:to_do_list_items].insert(
        user_id: user_id, to_do_list_id: to_do_list_id, name: name,
        assignee_id: assignee_id, due_by: due_by, completed: completed,
        refreshed: refreshed, created_at: Time.now, updated_at: Time.now
      )
    end
  end
end
