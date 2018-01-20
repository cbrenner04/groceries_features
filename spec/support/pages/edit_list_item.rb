# frozen_string_literal: true

module Pages
  # edit list page
  class EditListItem < SitePrism::Page
    set_url 'lists/{list_id}/{list_item_type}/{id}/edit'

    element :title, "input[name='itemTitle']"
    element :name, "input[name='itemName']"
    element :submit, "input[type='submit']"
  end
end
