# frozen_string_literal: true

module Pages
  # edit list page
  class ShareList < SitePrism::Page
    include TestSelectors

    set_url "/lists/{id}/users_lists"

    element :email, "#new-email"
    element :submit, "button[type='submit']"

    def has_write_badge?
      has_test_id?("perm-write")
    end

    def has_read_badge?
      has_test_id?("perm-read")
    end

    def has_no_write_badge?
      has_no_test_id?("perm-write")
    end

    def has_no_read_badge?
      has_no_test_id?("perm-read")
    end

    def write_badge
      find_by_test_id("perm-write")
    end

    def read_badge
      find_by_test_id("perm-read")
    end

    def share_list_with(user_id)
      find_by_test_id("invite-user-#{user_id}").click
    end

    def find_shared_user(user_id:, shared_state: "pending")
      find_by_test_id("#{shared_state}-user-#{user_id}")
    end

    def toggle_permissions(user_id:, shared_state: "accepted")
      user_element = find_shared_user(shared_state:, user_id:)
      find_by_test_id_within(user_element, "toggle-permissions").click
    end

    def refresh_share(user_id:)
      user_element = find_shared_user(shared_state: "refused", user_id:)
      find_by_test_id_within(user_element, "refresh-share").click
    end

    def remove_share(user_id:, shared_state: "accepted")
      user_element = find_shared_user(shared_state:, user_id:)
      find_by_test_id_within(user_element, "remove-share").click
    end
  end
end
