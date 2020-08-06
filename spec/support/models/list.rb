# frozen_string_literal: true

module Models
  # a list, not related to a user, holds items
  class List
    attr_accessor :name
    attr_reader :id, :type, :completed, :owner_id

    def initialize(type:, completed: false, create_list: true, owner_id:)
      @name = SecureRandom.hex(16)
      @type = type
      @completed = completed
      @owner_id = owner_id
      # must be last in order to have access to all attributes
      @id = create if create_list
    end

    private

    def create
      DB[:lists].insert(
        name: name, type: type, completed: completed, created_at: Time.now,
        updated_at: Time.now, owner_id: owner_id
      )
    end
  end
end
