# frozen_string_literal: true

module Pages
  # edit list page
  class EditListItem < SitePrism::Page
    include TestSelectors

    set_url "lists/{list_id}/list_items/{id}/edit"

    element :title_field, "#title"
    element :task, "#task"
    element :content, "#content"
    element :product, "#product"
    element :submit, "button[type='submit']"

    # Delegate title to title_field to avoid SitePrism blacklist issue
    def title
      title_field
    end
  end
end
