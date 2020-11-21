# frozen_string_literal: true

module Helpers
  # helpers for cleaning data
  class DataCleanUpHelper
    TABLES = %i[book_list_items grocery_list_items music_list_items simple_list_items to_do_list_items].freeze

    def initialize(database)
      @database = database
    end

    def remove_test_data
      set_instance_variables
      @users_lists.delete
      @user_ids.each { |id| TABLES.each { |table| @database[table].where(user_id: id).delete } }
      # for some reason when the above and the below are in the same loop, errors occur /shrug
      # rubocop:disable Style/CombinableLoops
      @user_ids.each { |id| @database[:lists].where(owner_id: id).delete }
      # rubocop:enable Style/CombinableLoops
      @lists.delete
      @users.delete
    end

    private

    def set_instance_variables
      @users = @database[:users].where(is_test_account: true)
      @user_ids = @users.map { |user| user[:id] }
      @users_lists = @database[:users_lists].where(user_id: @user_ids)
      list_ids = @users_lists.map { |list| list[:list_id] }
      @lists = @database[:lists].where(id: list_ids)
    end
  end
end
