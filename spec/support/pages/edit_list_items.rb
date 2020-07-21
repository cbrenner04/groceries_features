# frozen_string_literal: true

module Pages
  # edit list page
  class EditListItems < SitePrism::Page
    set_url 'lists/{list_id}/{list_item_type}/bulk_edit?item_ids={item_ids}'

    # change other list form
    element :copy, '#move-action-copy'
    element :move, '#move-action-move'
    element :new_list_name, '#newListName'
    element :existing_list, '#existingList'
    element :update_current_items, '#updateCurrentItems'

    # attribute inputs
    element :album, '#album'
    element :clear_album, '#clearAlbum'
    element :artist, '#artist'
    element :clear_artist, '#clearArtist'
    element :assignee, '#assigneeId'
    element :clear_assignee, '#clearAssignee'
    element :author, '#author'
    element :clear_author, '#clearAuthor'
    element :category, '#category'
    element :clear_category, '#clearCategory'
    element :due_by, '#dueBy'
    element :clear_due_by, '#clearDueBy'
    element :quantity, '#quantity'
    element :clear_quantity, '#clearQuantity'

    element :submit, "button[type='submit']"

    def all_links
      find_all('.btn.btn-link')
    end

    def create_new_list_link
      find('.btn.btn-link', text: 'Create new list')
    end

    def choose_existing_list_link
      find('.btn.btn-link', text: 'Choose existing list')
    end
  end
end
