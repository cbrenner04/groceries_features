# frozen_string_literal: true

module Pages
  # edit list page
  class EditListItems < SitePrism::Page
    include TestSelectors

    set_url "lists/{list_id}/{list_item_type}/bulk_edit?item_ids={item_ids}"

    # attribute inputs
    element :album, "#album"
    element :clear_album, "#clear_album"
    element :artist, "#artist"
    element :clear_artist, "#clear_artist"
    element :assignee, "#assignee_email"
    element :clear_assignee, "#clear_assignee_email"
    element :author, "#author"
    element :clear_author, "#clear_author"
    element :category, "#category"
    element :clear_category, "#clear_category"
    element :due_by, "#due_by"
    element :clear_due_by, "#clear_due_by"
    element :quantity, "#quantity"
    element :clear_quantity, "#clear_quantity"

    element :submit, "button[type='submit']"

    def create_new_list_link
      find(".btn.btn-link", text: "Create new list")
    end

    def choose_existing_list_link
      find(".btn.btn-link", text: "Choose existing list")
    end
  end
end
