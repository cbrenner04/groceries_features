# frozen_string_literal: true

module Pages
  # completed lists page, displays users completed lists
  class CompletedLists < SitePrism::Page
    include TestSelectors
    include Helpers::WaitHelper

    REFRESH_BUTTON_ID = "complete-list-refresh"

    set_url "/completed_lists"

    element :list_deleted_alert, ".Toastify", text: "List successfully deleted."

    def complete_list_names
      all_by_test_class("completed-list").map { |list| list.find("h5").text }
    end

    # Immediate version for post-wait_for assertions (no Capybara waiting)
    def complete_list_names_immediate
      all("[data-test-class='completed-list']", wait: 0).map { |list| list.find("h5", wait: 0).text }
    end

    def delete(list_name)
      list_element = find_complete_list(list_name)
      find_by_test_id_within(list_element, "complete-list-trash").click
    end

    def confirm_delete_button
      find_by_test_id("confirm-delete")
    end

    def find_complete_list(list_name)
      find_by_test_class("completed-list", text: list_name)
    end

    def refresh(list_name)
      list_element = find_complete_list(list_name)
      find_by_test_id_within(list_element, REFRESH_BUTTON_ID).click
    end

    def refresh_button_css
      "[data-test-id='#{REFRESH_BUTTON_ID}']"
    end

    # has_*? methods for elements that use data-test-* selectors
    def has_confirm_delete?
      has_test_id?("confirm-delete")
    end

    def has_complete_lists?
      has_test_class?("completed-list")
    end

    # has_no_*? methods for negative assertions
    def has_no_confirm_delete?
      has_no_test_id?("confirm-delete")
    end

    def has_no_complete_lists?
      has_no_test_class?("completed-list")
    end

    def wait_until_confirm_delete_button_visible
      wait_for { has_test_id?("confirm-delete") }
    end
  end
end
