# frozen_string_literal: true

module Pages
  # edit list page
  class ShareList < SitePrism::Page
    LIST_GROUP_ITEM_CLASS = '.list-group-item'

    set_url '/lists/{id}/users_lists/new'

    element :email, "input[name='newEmail']"
    element :submit, "input[type='submit']"

    def share_list_with(user_email)
      find(LIST_GROUP_ITEM_CLASS, text: user_email).click
    end
  end
end
