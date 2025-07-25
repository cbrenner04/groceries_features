# frozen_string_literal: true

module Models
  # an item on a book list
  class BookListItem
    attr_accessor :title
    attr_reader :id, :user_id, :list_id, :author, :completed, :read, :number_in_series, :category,
                :list_item_configuration_id

    def initialize(user_id:, list_id:, completed: false, read: false, category: nil, list_item_configuration_id: nil,
                   create_item: true)
      @user_id = user_id
      @list_id = list_id
      @author = SecureRandom.hex(16)
      @title = SecureRandom.hex(16)
      @completed = completed
      @read = read
      @number_in_series = 1
      @category = category
      @list_item_configuration_id = list_item_configuration_id
      @id = create if create_item
    end

    def pretty_title
      "\"#{title}\" #{author}"
    end

    private

    def create_individual_fields(list_item_id:, list_item_configuration_id:, attribute:, value:)
      field_configuration =
        DB[:list_item_field_configurations].where(list_item_configuration_id:, label: attribute).first
      ListItemField.new(list_item_field_configuration_id: field_configuration[:id], data: value, archived_at: nil,
                        user_id:, list_item_id:, create_field: true)
    end

    def create
      list_item = ListItem.new(user_id:, list_id:, create_item: true, completed:)
      create_individual_fields(list_item_id: list_item.id, list_item_configuration_id: list_item_configuration_id,
                               attribute: "author", value: author)
      create_individual_fields(list_item_id: list_item.id, list_item_configuration_id: list_item_configuration_id,
                               attribute: "title", value: title)
      create_individual_fields(list_item_id: list_item.id, list_item_configuration_id: list_item_configuration_id,
                               attribute: "read", value: read)
      create_individual_fields(list_item_id: list_item.id, list_item_configuration_id: list_item_configuration_id,
                               attribute: "number_in_series", value: number_in_series)
      create_individual_fields(list_item_id: list_item.id, list_item_configuration_id: list_item_configuration_id,
                               attribute: "category", value: category)
      list_item.id
    end
  end
end
