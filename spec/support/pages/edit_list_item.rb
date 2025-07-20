# frozen_string_literal: true

module Pages
  # edit list page
  class EditListItem < SitePrism::Page
    include TestSelectors

    set_url "lists/{list_id}/{list_item_type}/{id}/edit"

    element :title, "#title"
    element :task, "#task"
    element :content, "#content"
    element :product, "#product"
    element :submit, "button[type='submit']"
  end
end
