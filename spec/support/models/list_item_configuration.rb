# frozen_string_literal: true

module Models
  # a configuration for a list item
  class ListItemConfiguration
    attr_accessor :name, :archived_at, :user_id
    attr_reader :id, :created_at, :updated_at

    def initialize(name:, archived_at:, user_id:, create_configuration: true)
      @name = name
      @archived_at = archived_at
      @user_id = user_id
      @id = create if create_configuration
    end

    private

    def create
      DB[:list_item_configurations].insert(name:, archived_at:, user_id:,
                                           created_at: Time.now, updated_at: Time.now)
    end
  end
end
