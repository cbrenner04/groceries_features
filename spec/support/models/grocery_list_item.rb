# frozen_string_literal: true

module Models
  # an item on a grocery list
  class GroceryListItem
    attr_accessor :product
    attr_reader :id, :user_id, :list_id, :quantity, :completed, :refreshed, :category, :list_item_configuration_id

    def initialize(user_id:, list_id:, completed: false, category: nil, refreshed: false, list_item_configuration_id: nil, create_item: true)
      @user_id = user_id
      @list_id = list_id
      @product = SecureRandom.hex(16)
      @quantity = "#{rand(10)} #{SecureRandom.hex(8)}"
      @completed = completed
      @refreshed = refreshed
      @category = category
      @list_item_configuration_id = list_item_configuration_id
      @id = create if create_item
    end

    def pretty_title
      "#{quantity} #{product}"
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
                               attribute: "quantity", value: quantity)
      create_individual_fields(list_item_id: list_item.id, list_item_configuration_id: list_item_configuration_id,
                               attribute: "product", value: product)
      create_individual_fields(list_item_id: list_item.id, list_item_configuration_id: list_item_configuration_id,
                               attribute: "category", value: category)
      list_item.id
    end
  end
end
