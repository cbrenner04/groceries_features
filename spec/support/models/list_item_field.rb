# frozen_string_literal: true

module Models
  # a field on a list item
  class ListItemField
    attr_accessor :list_item_field_configuration_id, :data, :archived_at, :user_id, :list_item_id
    attr_reader :id, :created_at, :updated_at

    def initialize(list_item_field_configuration_id:, data:, archived_at:, user_id:, list_item_id:, create_field: true)
      @list_item_field_configuration_id = list_item_field_configuration_id
      @data = data
      @archived_at = archived_at
      @user_id = user_id
      @list_item_id = list_item_id
      @id = create if create_field
    end

    private

    def create
      DB[:list_item_fields].insert(list_item_field_configuration_id:, data:, archived_at:, user_id:, list_item_id:,
                                   created_at: Time.now, updated_at: Time.now)
    end
  end
end
