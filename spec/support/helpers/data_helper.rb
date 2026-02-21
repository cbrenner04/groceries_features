# frozen_string_literal: true

module Helpers
  # helpers for data manipulation
  module DataHelper
    def create_associated_list_objects(user, list)
      Models::UsersList.new(user_id: user.id, list_id: list.id)
      create_associated_items(user, list)
    end

    private

    def create_associated_items(user, list)
      list_item_configuration_id = DB[:lists].where(id: list.id).first[:list_item_configuration_id]

      # Seed category in categories table for test data
      seed_category(list.id, "foo")

      case list.template_name
      when "book list template"
        create_book_list_items(user, list, list_item_configuration_id)
      when "grocery list template"
        create_grocery_list_items(user, list, list_item_configuration_id)
      when "music list template"
        create_music_list_items(user, list, list_item_configuration_id)
      when "simple list with category template"
        create_simple_list_items(user, list, list_item_configuration_id)
      when "to do list template"
        create_todo_list_items(user, list, list_item_configuration_id)
      end
    end

    def seed_category(list_id, category_name)
      return if category_name.nil? || category_name.empty?

      # Check if category already exists for this list
      existing = DB[:categories].where(list_id:, name: category_name).first
      return if existing

      # Insert category
      DB[:categories].insert(list_id:, name: category_name, created_at: Time.now, updated_at: Time.now)
    end

    def create_book_list_items(user, list, list_item_configuration_id)
      [
        Models::BookListItem.new(user_id: user.id, list_id: list.id, category: "foo", list_item_configuration_id:),
        Models::BookListItem.new(user_id: user.id, list_id: list.id, list_item_configuration_id:),
        Models::BookListItem.new(user_id: user.id, list_id: list.id, completed: true, category: "foo",
                                 list_item_configuration_id:)
      ]
    end

    def create_grocery_list_items(user, list, list_item_configuration_id)
      [
        Models::GroceryListItem.new(user_id: user.id, list_id: list.id, category: "foo", list_item_configuration_id:),
        Models::GroceryListItem.new(user_id: user.id, list_id: list.id, list_item_configuration_id:),
        Models::GroceryListItem.new(user_id: user.id, list_id: list.id, completed: true, category: "foo",
                                    list_item_configuration_id:)
      ]
    end

    def create_music_list_items(user, list, list_item_configuration_id)
      [
        Models::MusicListItem.new(user_id: user.id, list_id: list.id, category: "foo", list_item_configuration_id:),
        Models::MusicListItem.new(user_id: user.id, list_id: list.id, list_item_configuration_id:),
        Models::MusicListItem.new(user_id: user.id, list_id: list.id, completed: true, category: "foo",
                                  list_item_configuration_id:)
      ]
    end

    def create_simple_list_items(user, list, list_item_configuration_id)
      [
        Models::SimpleListItem.new(user_id: user.id, list_id: list.id, category: "foo", list_item_configuration_id:),
        Models::SimpleListItem.new(user_id: user.id, list_id: list.id, list_item_configuration_id:),
        Models::SimpleListItem.new(user_id: user.id, list_id: list.id, completed: true, category: "foo",
                                   list_item_configuration_id:)
      ]
    end

    def create_todo_list_items(user, list, list_item_configuration_id)
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
