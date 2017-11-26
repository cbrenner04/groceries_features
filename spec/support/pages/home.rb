# frozen_string_literal: true

module Pages
  # app home page, displayed after log in, displays lists, includes edit page
  class Home < SitePrism::Page
    COMPLETE_LIST = "div[data-test-class='completed-list']"
    INCOMPLETE_LIST = "div[data-test-class='non-completed-list']"

    set_url '/'

    element :book_list, '#listType-BookList'
    element :grocery_list, '#listType-GroceryList'
    element :header, 'h1', text: 'Lists'
    element :music_list, '#listType-MusicList'
    element :name, "input[name='name']"
    element :submit, "input[type='submit']"
    element :to_do_list, '#listType-ToDoList'

    elements :complete_lists, COMPLETE_LIST
    elements :complete_list_names, "#{COMPLETE_LIST} h5"
    elements :incomplete_lists, INCOMPLETE_LIST
    elements :incomplete_list_names, "#{INCOMPLETE_LIST} h5"

    def complete(list_name)
      find(INCOMPLETE_LIST, text: list_name)
        .find('.fa.fa-check-square-o')
        .click
    end

    def edit(list_name)
      find(INCOMPLETE_LIST, text: list_name)
        .find('.fa.fa-pencil-square-o')
        .click
    end

    def refresh(list_name)
      find(COMPLETE_LIST, text: list_name).find('.fa.fa-refresh').click
    end
  end
end
