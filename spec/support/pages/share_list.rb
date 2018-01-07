# frozen_string_literal: true

module Pages
  # edit list page
  class ShareList < SitePrism::Page
    set_url '/lists/{id}/users_lists/new'

    element :email, "input[name='newEmail']"
    element :submit, "input[type='submit']"

    def share_list_with(user_email)
      find('.list-group-item', text: user_email).click
    end
  end
end
