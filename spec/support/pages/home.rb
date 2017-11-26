# frozen_string_literal: true

module Pages
  # app home page, displayed after log in, displays lists, includes edit page
  class Home < SitePrism::Page
    INCOMPLETE_LIST = "div[data-test-class='non-completed-list']"
    COMPLETE_LIST = "div[data-test-class='completed-list']"

    set_url '/'

    element :header, 'h1', text: 'Lists'
    element :name, "input[name='name']"
    element :book_list, '#listType-BookList'
    element :grocery_list, '#listType-GroceryList'
    element :music_list, '#listType-MusicList'
    element :to_do_list, '#listType-ToDoList'
    element :submit, "input[type='submit']"

    elements :incomplete_lists, INCOMPLETE_LIST
    elements :incomplete_list_names, "#{INCOMPLETE_LIST} h5"
    elements :complete_lists, COMPLETE_LIST
    elements :complete_list_names, "#{COMPLETE_LIST} h5"

    def edit(list_name)
      find(INCOMPLETE_LIST, text: list_name)
        .find('.fa.fa-pencil-square-o').click
    end

    def complete(list_name)
      find(INCOMPLETE_LIST, text: list_name)
        .find('.fa.fa-check-square-o').click
    end

    def refresh(list_name)
      find(COMPLETE_LIST, text: list_name).find('.fa.fa-refresh').click
    end
  end
end
