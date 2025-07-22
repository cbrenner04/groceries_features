# frozen_string_literal: true

module Helpers
  # helpers for data manipulation
  module DataHelper
    def create_associated_list_objects(user, list, skip_field_configuration: false)
      Models::UsersList.new(user_id: user.id, list_id: list.id)
      create_associated_items(user, list, skip_field_configuration:)
    end

    private

    def create_associated_items(user, list, skip_field_configuration: false)
      case list.type
      when "BookList"
        create_book_list_items(user, list, skip_field_configuration:)
      when "GroceryList"
        create_grocery_list_items(user, list, skip_field_configuration:)
      when "MusicList"
        create_music_list_items(user, list, skip_field_configuration:)
      when "SimpleList"
        create_simple_list_items(user, list, skip_field_configuration:)
      when "ToDoList"
        create_todo_list_items(user, list, skip_field_configuration:)
      end
    end

    def create_book_list_items(user, list, skip_field_configuration: false)
      list_item_configuration_id = DB[:lists].where(id: list.id).first[:list_item_configuration_id]
      unless skip_field_configuration
        Models::ListItemFieldConfiguration.new(label: "author", data_type: "free_text", archived_at: nil,
                                              list_item_configuration_id:, position: 1, create_field: true)
        Models::ListItemFieldConfiguration.new(label: "title", data_type: "free_text", archived_at: nil,
                                              list_item_configuration_id:, position: 2, create_field: true)
        Models::ListItemFieldConfiguration.new(label: "read", data_type: "boolean", archived_at: nil,
                                              list_item_configuration_id:, position: 3, create_field: true)
        Models::ListItemFieldConfiguration.new(label: "number_in_series", data_type: "integer", archived_at: nil,
                                              list_item_configuration_id:, position: 4, create_field: true)
        Models::ListItemFieldConfiguration.new(label: "category", data_type: "free_text", archived_at: nil,
                                              list_item_configuration_id:, position: 5, create_field: true)
      end

      [
        Models::BookListItem.new(user_id: user.id, list_id: list.id, category: "foo", list_item_configuration_id:),
        Models::BookListItem.new(user_id: user.id, list_id: list.id, list_item_configuration_id:),
        Models::BookListItem.new(user_id: user.id, list_id: list.id, completed: true, category: "foo",
                                 list_item_configuration_id:)
      ]
    end

    def create_grocery_list_items(user, list, skip_field_configuration: false)
      list_item_configuration_id = DB[:lists].where(id: list.id).first[:list_item_configuration_id]
      unless skip_field_configuration
        Models::ListItemFieldConfiguration.new(label: "quantity", data_type: "integer", archived_at: nil,
                                             list_item_configuration_id:, position: 1, create_field: true)
        Models::ListItemFieldConfiguration.new(label: "product", data_type: "free_text", archived_at: nil,
                                             list_item_configuration_id:, position: 2, create_field: true)
        Models::ListItemFieldConfiguration.new(label: "category", data_type: "free_text", archived_at: nil,
                                               list_item_configuration_id:, position: 3, create_field: true)
      end
      [
        Models::GroceryListItem.new(user_id: user.id, list_id: list.id, category: "foo", list_item_configuration_id:),
        Models::GroceryListItem.new(user_id: user.id, list_id: list.id, list_item_configuration_id:),
        Models::GroceryListItem.new(user_id: user.id, list_id: list.id, completed: true, category: "foo",
                                    list_item_configuration_id:)
      ]
    end

    def create_music_list_items(user, list, skip_field_configuration: false)
      list_item_configuration_id = DB[:lists].where(id: list.id).first[:list_item_configuration_id]
      unless skip_field_configuration
        Models::ListItemFieldConfiguration.new(label: "title", data_type: "free_text", archived_at: nil,
                                             list_item_configuration_id:, position: 1, create_field: true)
        Models::ListItemFieldConfiguration.new(label: "artist", data_type: "free_text", archived_at: nil,
                                             list_item_configuration_id:, position: 2, create_field: true)
        Models::ListItemFieldConfiguration.new(label: "album", data_type: "free_text", archived_at: nil,
                                               list_item_configuration_id:, position: 3, create_field: true)
        Models::ListItemFieldConfiguration.new(label: "category", data_type: "free_text", archived_at: nil,
                                               list_item_configuration_id:, position: 4, create_field: true)
      end
      [
        Models::MusicListItem.new(user_id: user.id, list_id: list.id, category: "foo", list_item_configuration_id:),
        Models::MusicListItem.new(user_id: user.id, list_id: list.id, list_item_configuration_id:),
        Models::MusicListItem.new(user_id: user.id, list_id: list.id, completed: true, category: "foo",
                                  list_item_configuration_id:)
      ]
    end

    def create_simple_list_items(user, list, skip_field_configuration: false)
      list_item_configuration_id = DB[:lists].where(id: list.id).first[:list_item_configuration_id]
      unless skip_field_configuration
        Models::ListItemFieldConfiguration.new(label: "content", data_type: "free_text", archived_at: nil,
                                             list_item_configuration_id:, position: 1, create_field: true)
        Models::ListItemFieldConfiguration.new(label: "category", data_type: "free_text", archived_at: nil,
                                               list_item_configuration_id:, position: 2, create_field: true)
      end
      [
        Models::SimpleListItem.new(user_id: user.id, list_id: list.id, category: "foo", list_item_configuration_id:),
        Models::SimpleListItem.new(user_id: user.id, list_id: list.id, list_item_configuration_id:),
        Models::SimpleListItem.new(user_id: user.id, list_id: list.id, completed: true, category: "foo",
                                   list_item_configuration_id:)
      ]
    end

    def create_todo_list_items(user, list, skip_field_configuration: false)
      list_item_configuration_id = DB[:lists].where(id: list.id).first[:list_item_configuration_id]
      unless skip_field_configuration
        Models::ListItemFieldConfiguration.new(label: "task", data_type: "free_text", archived_at: nil,
                                             list_item_configuration_id:, position: 1, create_field: true)
        Models::ListItemFieldConfiguration.new(label: "due_by", data_type: "date", archived_at: nil,
                                             list_item_configuration_id:, position: 2, create_field: true)
        # TODO: this isn't exactly right
        Models::ListItemFieldConfiguration.new(label: "assignee_email", data_type: "free_text", archived_at: nil,
                                             list_item_configuration_id:, position: 3, create_field: true)
        Models::ListItemFieldConfiguration.new(label: "category", data_type: "free_text", archived_at: nil,
                                               list_item_configuration_id:, position: 4, create_field: true)
      end
      [
        Models::ToDoListItem.new(user_id: user.id, list_id: list.id, assignee_email: user.email, category: "foo",
                                 list_item_configuration_id:),
        Models::ToDoListItem.new(user_id: user.id, list_id: list.id, assignee_email: user.email,
                                 list_item_configuration_id:),
        Models::ToDoListItem.new(user_id: user.id, list_id: list.id, assignee_email: user.email, completed: true,
                                 category: "foo", list_item_configuration_id:)
      ]
    end
  end
end
