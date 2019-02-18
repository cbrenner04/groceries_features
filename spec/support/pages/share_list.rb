# frozen_string_literal: true

module Pages
  # edit list page
  class ShareList < SitePrism::Page
    SHARE_LIST_ID = '#invite-user'

    set_url '/lists/{id}/users_lists/new'

    element :email, "input[name='newEmail']"
    element :submit, "button[type='submit']"
    element :write_badge, '#perm-write'
    element :read_badge, '#perm-read'

    def share_list_with(user_id)
      find("#{SHARE_LIST_ID}-#{user_id}").click
    end

    def toggle_permissions(shared_state: 'accepted', user_id:)
      find("##{shared_state}-user-#{user_id}").click
    end
  end
end
