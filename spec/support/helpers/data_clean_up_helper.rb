# frozen_string_literal: true

module Helpers
  # helpers for cleaning data
  class DataCleanUpHelper
    TABLES = %i[book_list_items grocery_list_items music_list_items
                to_do_list_items].freeze

    def initialize(database)
      @database = database
    end

    def remove_test_data
      set_instance_variables
      @user_ids.each do |id|
        TABLES.each { |table| @database[table].where(user_id: id).delete }
      end
      @users_lists.delete
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