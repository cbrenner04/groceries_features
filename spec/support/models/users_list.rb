# frozen_string_literal: true

module Models
  # a user of the application
  class UsersList
    attr_reader :id, :user_id, :list_id, :has_accepted, :responded

    def initialize(user_id:, list_id:, has_accepted: true, responded: true,
                   create_list: true)
      @user_id = user_id
      @list_id = list_id
      @has_accepted = has_accepted
      @responded = responded
      @id = create if create_list
    end

    def create
      DB[:users_lists].insert(
        user_id: user_id, list_id: list_id, has_accepted: has_accepted,
        responded: responded
      )
    end
  end
end
