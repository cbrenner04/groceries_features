# frozen_string_literal: true

module Pages
  # edit list page
  class EditList < SitePrism::Page
    set_url '/lists/{id}/edit'

    element :name, "input[name='listName']"
    element :submit, "button[type='submit']"
  end
end
