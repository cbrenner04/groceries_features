# frozen_string_literal: true

module Models
  # a list, not related to a user, holds items
  class List
    attr_accessor :name
    attr_reader :id, :completed, :owner_id, :list_item_configuration, :template_name

    def initialize(template_name:, owner_id:, completed: false, list_item_configuration: nil, create_list: true)
      @name = SecureRandom.hex(16)
      @template_name = template_name
      @completed = completed
      @owner_id = owner_id
      @list_item_configuration = list_item_configuration
      # must be last in order to have access to all attributes
      @id = create if create_list
    end

    private

    def create
      @list_item_configuration ||= ListItemConfiguration.find_by_name(owner_id, template_name)
      DB[:lists].insert(name:, completed:, created_at: Time.now, updated_at: Time.now, owner_id:,
                        list_item_configuration_id: list_item_configuration.id)
    end
  end
end
