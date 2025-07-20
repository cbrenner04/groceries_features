# frozen_string_literal: true

module Helpers
  # helpers for cleaning data
  class DataCleanUpHelper
    TABLES = %i[list_items list_item_fields].freeze

    def initialize(database)
      @database = database
    end

    def remove_test_data
      set_instance_variables
      @users_lists.delete
      @user_ids.each do |user_id|
        list_item_configurations = @database[:list_item_configurations].where(user_id:)

        return if list_item_configurations.empty?

        list_item_configurations.each do |list_item_configuration|
          field_configurations = @database[:list_item_field_configurations]
                                 .where(list_item_configuration_id: list_item_configuration[:id])

          next if field_configurations.empty?

          field_configurations.each do |field_configuration|
            @database[:list_item_fields].where(list_item_field_configuration_id: field_configuration[:id]).delete
          end
          field_configurations.delete
        end
        list_item_configurations.delete
      end
      @user_ids.each { |id| TABLES.each {|table| @database[table].where(user_id: id).delete } }
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
