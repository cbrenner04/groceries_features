# frozen_string_literal: true

module Pages
  # edit list page
  class EditList < SitePrism::Page
    include TestSelectors

    set_url "/lists/{id}/edit"

    element :name, "#name"
    element :submit, "[type='submit']"
  end
end
