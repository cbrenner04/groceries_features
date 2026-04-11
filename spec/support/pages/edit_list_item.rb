# frozen_string_literal: true

module Pages
  # edit list item — renders as a bottom sheet on the list page
  class EditListItem < SitePrism::Page
    include TestSelectors

    set_url "lists/{list_id}/list_items/{id}/edit"

    element :title_field, "#title"
    element :task, "#task"
    element :content, "#content"
    element :product, "#product"
    element :submit, "button[type='submit']"
    element :edit_sheet, "[data-test-id='edit-item-sheet']"

    # Delegate title to title_field to avoid SitePrism blacklist issue
    def title
      title_field
    end

    def has_edit_sheet?
      has_test_id?("edit-item-sheet")
    end

    def wait_for_sheet
      wait_for { has_edit_sheet? }
    end
  end
end
