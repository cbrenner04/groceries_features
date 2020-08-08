# frozen_string_literal: true

module Pages
  # edit list page
  class ShareList < SitePrism::Page
    WRITE_BADGE = '[data-test-id="perm-write"]'
    READ_BADGE = '[data-test-id="perm-read"]'

    set_url "/lists/{id}/users_lists"

    element :email, "#new-email"
    element :submit, "button[type='submit']"
    element :write_badge, WRITE_BADGE
    element :read_badge, READ_BADGE

    def write_badge_css
      WRITE_BADGE
    end

    def read_badge_css
      READ_BADGE
    end

    def share_list_with(user_id)
      find("[data-test-id='invite-user-#{user_id}']").click
    end

    def find_shared_user(shared_state: "pending", user_id:)
      find("[data-test-id='#{shared_state}-user-#{user_id}']")
    end

    def toggle_permissions(shared_state: "accepted", user_id:)
      find_shared_user(shared_state: shared_state, user_id: user_id).find("[data-test-id='toggle-permissions']").click
    end

    def refresh_share(user_id:)
      find_shared_user(shared_state: "refused", user_id: user_id).find("[data-test-id='refresh-share']").click
    end

    def remove_share(shared_state: "accepted", user_id:)
      find_shared_user(shared_state: shared_state, user_id: user_id).find("[data-test-id='remove-share']").click
    end
  end
end
