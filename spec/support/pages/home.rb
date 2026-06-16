# frozen_string_literal: true

module Pages
  # app home page, displayed after log in, displays lists
  class Home < SitePrism::Page
    include TestSelectors
    include Helpers::WaitHelper

    set_url "/"

    element :signed_in_alert, ".Toastify", text: "Signed in successfully"
    element :list_deleted_alert, ".Toastify", text: "List successfully deleted."
    element :list_template, "#list_item_configuration_id"
    element :new_merged_list_name_input, "#mergeName"
    element :header, "[data-test-id='page-title']"

    elements :multi_select_buttons, :button, "Select"

    # has_*? methods for elements that use data-test-* selectors
    def has_log_out?
      has_test_id?("log-out-link")
    end

    def has_invite?
      has_test_id?("nav-invite")
    end

    def has_confirm_delete?
      has_test_id?("confirm-delete")
    end

    def has_confirm_reject?
      has_test_id?("confirm-reject")
    end

    def has_confirm_merge?
      has_test_id?("confirm-merge")
    end

    def has_completed_lists?
      has_test_class?("completed-list")
    end

    def has_incomplete_lists?
      has_test_class?("incomplete-list")
    end

    def has_pending_lists?
      has_test_class?("pending-list")
    end

    # has_no_*? methods for negative assertions
    def has_no_log_out?
      has_no_test_id?("log-out-link")
    end

    def has_no_invite?
      has_no_test_id?("nav-invite")
    end

    def has_no_completed_lists?
      has_no_test_class?("completed-list")
    end

    def has_no_incomplete_lists?
      has_no_test_class?("incomplete-list")
    end

    def has_no_pending_lists?
      has_no_test_class?("pending-list")
    end

    def has_no_share_button?
      has_no_test_id?("incomplete-list-share")
    end

    def has_no_edit_button?
      has_no_test_id?("incomplete-list-edit")
    end

    def has_page_title?
      has_test_id?("page-title")
    end

    def has_settings_nav?
      has_test_id?("nav-settings")
    end

    def page_title
      find_by_test_id("page-title")
    end

    def settings_nav
      find_by_test_id("nav-settings")
    end

    def completed_lists_nav
      find_by_test_id("nav-completed")
    end

    def go_to_completed_lists
      completed_lists_nav
    end

    def invite
      find_by_test_id("nav-invite")
    end

    def log_out
      find_by_test_id("log-out-link")
    end

    def confirm_delete_button
      find("[data-test-id='confirm-delete']", visible: :all)
    end

    def confirm_reject_button
      find("[data-test-id='confirm-reject']", visible: :all)
    end

    def confirm_merge_button
      find_by_test_id("confirm-merge")
    end

    def complete_lists
      all_by_test_class("completed-list")
    end

    def complete_list_names
      all_by_test_class("completed-list").map do |list|
        find_by_test_id_within(list, "list-name").text
      end
    end

    def incomplete_lists
      all_by_test_class("incomplete-list")
    end

    def incomplete_list_names
      all_by_test_class("incomplete-list").map do |list|
        find_by_test_id_within(list, "list-name").text
      end
    end

    def pending_list_names
      all_by_test_class("pending-list").map do |list|
        find_by_test_id_within(list, "list-name").text
      end
    end

    # Immediate versions for post-wait_for assertions (no Capybara waiting)
    def incomplete_list_names_immediate
      all("[data-test-class='incomplete-list']", wait: 0).map do |list|
        list.find("[data-test-id='list-name']", wait: 0).text
      end
    end

    def pending_list_names_immediate
      all("[data-test-class='pending-list']", wait: 0).map do |list|
        list.find("[data-test-id='list-name']", wait: 0).text
      end
    end

    def complete_list_names_immediate
      all("[data-test-class='completed-list']", wait: 0).map do |list|
        list.find("[data-test-id='list-name']", wait: 0).text
      end
    end

    def incomplete_lists_immediate
      all("[data-test-class='incomplete-list']", wait: 0)
    end

    def select_list(list_name)
      # Find the list card by searching for the list-name within a list card
      # This is more specific than just searching by test-class
      # Note: [data-test-id^="list-"] alone matches both Card elements and the list-name span,
      # so we add [data-test-class] to match only Card containers
      list_card = all('[data-test-id^="list-"][data-test-class]').detect do |card|
        card.find('[data-test-id="list-name"]').text == list_name
      end
      list_card&.click
    end

    def find_pending_list(list_name)
      find_by_test_class("pending-list", text: list_name)
    end

    def find_incomplete_list(list_name)
      find_by_test_class("incomplete-list", text: list_name)
    end

    def find_complete_list(list_name)
      find_by_test_class("completed-list", text: list_name)
    end

    def multi_select_list(list_name, complete: false)
      list_element = multi_select_list_element(list_name, complete: complete)

      list_element.find("input").click
    end

    def multi_select_list_element(list_name, complete: false)
      complete ? find_complete_list(list_name) : find_incomplete_list(list_name)
    end

    def accept_button_css
      "[data-test-id='pending-list-accept']"
    end

    def reject_button_css
      "[data-test-id='pending-list-trash']"
    end

    def accept(list_name)
      list_element = find_pending_list(list_name)
      find_by_test_id_within(list_element, "pending-list-accept").click
    end

    def reject(list_name)
      list_element = find_pending_list(list_name)
      click_list_action(list_element, "pending-list-trash")
    end

    def complete(list_name)
      list_element = find_incomplete_list(list_name)
      click_list_action(list_element, "incomplete-list-complete")
    end

    def complete_button_css
      "[data-test-id='incomplete-list-complete']"
    end

    def has_share_button?
      has_test_id?("incomplete-list-share")
    end

    def share_button_css
      "[data-test-id='incomplete-list-share']"
    end

    def has_edit_button?
      has_test_id?("incomplete-list-edit")
    end

    def edit_button_css
      "[data-test-id='incomplete-list-edit']"
    end

    def share(list_name)
      list_element = find_incomplete_list(list_name)
      find_by_test_id_within(list_element, "incomplete-list-share").click
    end

    def edit(list_name)
      click_list_action(find_incomplete_list(list_name), "incomplete-list-edit")
      wait_for do
        if has_css?("[data-test-id='edit-list-sheet']", visible: :all, wait: 0) &&
           has_css?("#name", visible: :all, wait: 0)
          true
        else
          click_list_action(find_incomplete_list(list_name), "incomplete-list-edit")
          false
        end
      rescue Capybara::ElementNotFound
        click_list_action(find_incomplete_list(list_name), "incomplete-list-edit")
        false
      end
    end

    def merge_button
      find_by_test_id("multi-select-merge")
    end

    def incomplete_delete_button_css
      "[data-test-id='incomplete-list-trash']"
    end

    def complete_delete_button_css
      "[data-test-id='complete-list-trash']"
    end

    def delete(list_name, complete: false)
      list_element = complete ? find_complete_list(list_name) : find_incomplete_list(list_name)
      test_id = complete ? "complete-list-trash" : "incomplete-list-trash"
      click_list_action(list_element, test_id)
    end

    def refresh_button_css
      "[data-test-id='complete-list-refresh']"
    end

    def refresh(list_name)
      list_element = find_complete_list(list_name)
      click_list_action(list_element, "complete-list-refresh")
    end

    def status_filter(status)
      find_by_test_id("filter-#{status}")
    end

    def quick_add_expand
      find_by_test_id("quick-add-expand")
    end

    def name
      find_by_test_id("quick-add-input")
    end

    def wait_until_settings_nav_visible
      wait_for { has_test_id?("nav-settings") }
    end

    def wait_until_confirm_delete_button_visible(list_name)
      wait_for do
        has_css?("[data-test-id='confirm-modal-body']", visible: :all, wait: 0) &&
          find("[data-test-id='confirm-modal-body']", visible: :all, wait: 0).text.include?(list_name) &&
          has_css?("[data-test-id='confirm-delete']", visible: :all, wait: 0)
      rescue Capybara::ElementNotFound
        false
      end
    end

    def wait_until_confirm_reject_button_visible(list_name)
      wait_for do
        has_css?("[data-test-id='confirm-modal-body']", visible: :all, wait: 0) &&
          find("[data-test-id='confirm-modal-body']", visible: :all, wait: 0).text.include?(list_name) &&
          has_css?("[data-test-id='confirm-reject']", visible: :all, wait: 0)
      rescue Capybara::ElementNotFound
        false
      end
    end

    def click_list_action(list_element, test_id)
      button = list_element.find(:css, "[data-test-id='#{test_id}']:not([disabled])")
      scroll_to(button)
      page.execute_script("arguments[0].click();", button.native)
    end

    def click_confirm_delete
      button = find("[data-test-id='confirm-delete']", visible: :all)
      page.execute_script("arguments[0].click();", button.native)
    end

    def click_confirm_reject
      button = find("[data-test-id='confirm-reject']", visible: :all)
      page.execute_script("arguments[0].click();", button.native)
    end

    def list_id_from(list_element)
      list_element["data-test-id"].delete_prefix("list-")
    end

    def has_merge_warning?
      has_text?("Only lists of the same type can be merged")
    end

    def has_merge_breakdown?
      has_text?("Lists to be merged") && has_text?("Lists excluded")
    end

    def merge_warning_text
      find_by_test_id("merge-warning").text
    end

    def merge_breakdown_text
      find_by_test_id("merge-breakdown").text
    end

    def has_clear_merge_button?
      has_test_id?("clear-merge")
    end

    def has_no_merge_warning?
      has_no_text?("Only lists of the same type can be merged")
    end

    def has_no_merge_breakdown?
      has_no_text?("Lists to be merged") && has_no_text?("Lists excluded")
    end

    def has_no_confirm_merge?
      has_no_test_id?("confirm-merge")
    end

    def clear_merge_button
      find_by_test_id("clear-merge")
    end
  end
end
