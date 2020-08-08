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
      case list.type
      when "BookList"
        create_book_list_items(user, list)
      when "GroceryList"
        create_grocery_list_items(user, list)
      when "MusicList"
        create_music_list_items(user, list)
      when "ToDoList"
        create_todo_list_items(user, list)
      end
    end

    def create_book_list_items(user, list)
      [
        Models::BookListItem.new(user_id: user.id, book_list_id: list.id, category: "foo"),
        Models::BookListItem.new(user_id: user.id, book_list_id: list.id),
        Models::BookListItem.new(user_id: user.id, book_list_id: list.id, purchased: true, category: "foo")
      ]
    end

    def create_grocery_list_items(user, list)
      [
        Models::GroceryListItem.new(user_id: user.id, grocery_list_id: list.id, category: "foo"),
        Models::GroceryListItem.new(user_id: user.id, grocery_list_id: list.id),
        Models::GroceryListItem.new(user_id: user.id, grocery_list_id: list.id, purchased: true, category: "foo")
      ]
    end

    def create_music_list_items(user, list)
      [
        Models::MusicListItem.new(user_id: user.id, music_list_id: list.id, category: "foo"),
        Models::MusicListItem.new(user_id: user.id, music_list_id: list.id),
        Models::MusicListItem.new(user_id: user.id, music_list_id: list.id, purchased: true, category: "foo")
      ]
    end

    def create_todo_list_items(user, list)
      [
        Models::ToDoListItem.new(user_id: user.id, to_do_list_id: list.id, category: "foo"),
        Models::ToDoListItem.new(user_id: user.id, to_do_list_id: list.id),
        Models::ToDoListItem.new(user_id: user.id, to_do_list_id: list.id, completed: true, category: "foo")
      ]
    end
  end
end
