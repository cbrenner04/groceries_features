# frozen_string_literal: true

module Models
  # a configuration for a field on a list item
  class ListItemFieldConfiguration
    attr_accessor :label, :data_type, :archived_at, :list_item_configuration_id, :position
    attr_reader :id, :created_at, :updated_at

    def initialize(label:, data_type:, archived_at:, list_item_configuration_id:, position:, create_field: true)
      @label = label
      @data_type = data_type
      @archived_at = archived_at
      @list_item_configuration_id = list_item_configuration_id
      @position = position
      @id = create if create_field
    end

    private

    def create
      DB[:list_item_field_configurations].insert(label:, data_type:, archived_at:, list_item_configuration_id:,
                                                 position:, created_at: Time.now, updated_at: Time.now)
    end
  end
end
