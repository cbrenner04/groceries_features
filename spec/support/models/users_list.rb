# frozen_string_literal: true

module Models
  # relates a user and a list
  class UsersList
    attr_reader :id, :user_id, :list_id, :has_accepted, :permissions

    def initialize(user_id:, list_id:, has_accepted: true, permissions: "write", create_list: true)
      @user_id = user_id
      @list_id = list_id
      @has_accepted = has_accepted
      @permissions = permissions
      @id = create if create_list
    end

    private

    def create
      DB[:users_lists].insert(user_id:, list_id:, has_accepted:, permissions:)
    end
  end
end
