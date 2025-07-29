# frozen_string_literal: true

module Models
  # an item on a to do list
  class ToDoListItem
    ONE_MINUTE = 60
    ONE_HOUR = ONE_MINUTE * 60
    ONE_DAY = ONE_HOUR * 24

    attr_accessor :task, :due_by, :assignee_email
    attr_reader :id, :user_id, :list_id, :completed, :refreshed, :category, :list_item_configuration_id

    def initialize(user_id:, list_id:, assignee_email: nil, completed: false, category: nil, refreshed: false,
                   list_item_configuration_id: nil, create_item: true)
      @user_id = user_id
      @list_id = list_id
      @list_item_configuration_id = list_item_configuration_id
      @task = SecureRandom.hex(16)
      @assignee_email = assignee_email || DB[:users].first[:email]
      @due_by = Time.now + (rand(180) * ONE_DAY)
      @completed = completed
      @refreshed = refreshed
      @category = category
      @id = create if create_item
    end

    def pretty_title
      adjusted_due_by = due_by - (5 * ONE_HOUR)
      assignee = "Assigned To: #{assignee_email}"
      "#{task} #{assignee} Due By: #{adjusted_due_by.strftime('%B %-d, %Y')}"
    end

    private

    def create_individual_fields(list_item_id:, list_item_configuration_id:, attribute:, value:)
      field_configuration =
        DB[:list_item_field_configurations].where(list_item_configuration_id:, label: attribute).first
      ListItemField.new(list_item_field_configuration_id: field_configuration[:id], data: value, archived_at: nil,
                        user_id:, list_item_id:, create_field: true)
    end

    def create
      list_item = ListItem.new(user_id:, list_id:, create_item: true, completed:, refreshed:)
      create_individual_fields(list_item_id: list_item.id, list_item_configuration_id: list_item_configuration_id,
                               attribute: "task", value: task)
      create_individual_fields(list_item_id: list_item.id, list_item_configuration_id: list_item_configuration_id,
                               attribute: "due_by", value: due_by)
      create_individual_fields(list_item_id: list_item.id, list_item_configuration_id: list_item_configuration_id,
                               attribute: "assignee_email", value: assignee_email)
      create_individual_fields(list_item_id: list_item.id, list_item_configuration_id: list_item_configuration_id,
                               attribute: "category", value: category)
      list_item.id
    end
  end
end
