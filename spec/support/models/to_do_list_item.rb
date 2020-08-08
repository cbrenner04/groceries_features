# frozen_string_literal: true

module Models
  # an item on a to do list
  class ToDoListItem
    ONE_MINUTE = 60
    ONE_HOUR = ONE_MINUTE * 60
    ONE_DAY = ONE_HOUR * 24

    attr_accessor :task, :due_by
    attr_reader :id, :user_id, :to_do_list_id, :assignee_id, :completed, :refreshed, :category

    def initialize(user_id:, to_do_list_id:, assignee_id: nil, completed: false, category: nil, refreshed: false,
                   create_item: true)
      @user_id = user_id
      @to_do_list_id = to_do_list_id
      @task = SecureRandom.hex(16)
      @assignee_id = assignee_id
      @due_by = Time.now + (rand(180) * ONE_DAY)
      @completed = completed
      @refreshed = refreshed
      @category = category
      @id = create if create_item
    end

    def pretty_title
      # TODO: deal with timezones
      adjusted_due_by = due_by - 5 * ONE_HOUR
      "#{task}\nDue By: #{adjusted_due_by.strftime('%B %-d, %Y')}"
    end

    private

    def create
      DB[:to_do_list_items].insert(user_id: user_id, to_do_list_id: to_do_list_id, task: task,
                                   assignee_id: assignee_id, due_by: due_by, completed: completed, refreshed: refreshed,
                                   created_at: Time.now, updated_at: Time.now, category: category)
    end
  end
end
