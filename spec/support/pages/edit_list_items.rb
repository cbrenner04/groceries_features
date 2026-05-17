# frozen_string_literal: true

module Pages
  # edit list page
  class EditListItems < SitePrism::Page
    include TestSelectors

    set_url "lists/{list_id}/list_items/bulk-edit?item_ids={item_ids}"

    # attribute inputs (scoped to bulk sheet — list page quick-add can reuse the same ids)
    element :album, "[data-test-id='bulk-edit-sheet'] #album"
    element :clear_album, "[data-test-id='bulk-edit-sheet'] #clear_album"
    element :artist, "[data-test-id='bulk-edit-sheet'] #artist"
    element :clear_artist, "[data-test-id='bulk-edit-sheet'] #clear_artist"
    element :assignee, "[data-test-id='bulk-edit-sheet'] #assignee"
    element :clear_assignee, "[data-test-id='bulk-edit-sheet'] #clear_assignee"
    element :author, "[data-test-id='bulk-edit-sheet'] #author"
    element :clear_author, "[data-test-id='bulk-edit-sheet'] #clear_author"
    element :category, "[data-test-id='bulk-edit-sheet'] [data-test-id='category-field'] input[name='category']"
    element :clear_category, "[data-test-id='bulk-edit-sheet'] #clear_category"
    element :due_by, "[data-test-id='bulk-edit-sheet'] #due\\ by"
    element :clear_due_by, "[data-test-id='bulk-edit-sheet'] #clear_due\\ by"
    element :quantity, "[data-test-id='bulk-edit-sheet'] #quantity"
    element :clear_quantity, "[data-test-id='bulk-edit-sheet'] #clear_quantity"

    element :submit, "button[type='submit']"

    def create_new_list_link
      find_by_test_id("create-new-list-link")
    end

    def choose_existing_list_link
      find_by_test_id("choose-existing-list-link")
    end

    # Fixed BottomInputBar can intercept native clicks; requestSubmit runs the form handler reliably.
    def submit_form
      form = find(:css, "[data-test-id='bulk-edit-sheet'] form", match: :first)
      page.execute_script("arguments[0].requestSubmit();", form.native)
    end
  end
end
