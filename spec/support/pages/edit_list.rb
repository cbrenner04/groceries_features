# frozen_string_literal: true

module Pages
  # edit list page
  class EditList < SitePrism::Page
    set_url '/lists/{id}/edit'

    element :name, "input[name='name']"
    element :submit, "input[type='submit']"
  end
end
