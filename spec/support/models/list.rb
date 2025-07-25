# frozen_string_literal: true

module Models
  # a list, not related to a user, holds items
  class List
    attr_accessor :name
    attr_reader :id, :type, :completed, :owner_id, :list_item_configuration

    def initialize(type:, owner_id:, completed: false, list_item_configuration: nil, create_list: true)
      @name = SecureRandom.hex(16)
      @type = type
      @completed = completed
      @owner_id = owner_id
      @list_item_configuration = list_item_configuration
      # must be last in order to have access to all attributes
      @id = create if create_list
    end

    private

    def create
      @list_item_configuration ||=
        ListItemConfiguration.new(name: SecureRandom.hex(16), archived_at: nil, user_id: owner_id,
                                  create_configuration: true)
      DB[:lists].insert(name:, type:, completed:, created_at: Time.now, updated_at: Time.now, owner_id:,
                        list_item_configuration_id: list_item_configuration.id)
    end
  end
end
