# frozen_string_literal: true

module Pages
  # app home page, displayed after log in, displays lists
  # rubocop:disable Metrics/ClassLength
  class Home < SitePrism::Page
    include TestSelectors
    include Helpers::WaitHelper

    set_url "/"

    element :signed_in_alert, ".Toastify", text: "Signed in successfully"
    element :list_deleted_alert, ".Toastify", text: "List successfully deleted."
    element :list_type, "#type"
    element :header, "h1", text: "Lists"
    element :name, "#name"
    element :submit, "button[type='submit']"
    element :new_merged_list_name_input, "#mergeName"

    elements :multi_select_buttons, :button, "Select"

    # has_*? methods for elements that use data-test-* selectors
    def has_log_out?
      has_test_id?("log-out-link")
    end

    def has_invite?
      has_test_id?("invite-link")
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
      has_no_test_id?("invite-link")
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

    def go_to_completed_lists
      click_on "See all completed lists here"
    end

    def invite
      find_by_test_id("invite-link")
    end

    def log_out
      find_by_test_id("log-out-link")
    end

    def confirm_delete_button
      find_by_test_id("confirm-delete")
    end

    def confirm_reject_button
      find_by_test_id("confirm-reject")
    end

    def confirm_merge_button
      find_by_test_id("confirm-merge")
    end

    def complete_lists
      all_by_test_class("completed-list")
    end

    def complete_list_names
      all_by_test_class("completed-list").map { |list| list.find("h5").text }
    end

    def incomplete_lists
      all_by_test_class("incomplete-list")
    end

    def incomplete_list_names
      all_by_test_class("incomplete-list").map { |list| list.find("h5").text }
    end

    def pending_list_names
      all_by_test_class("pending-list").map { |list| list.find("h5").text }
    end

    def select_list(list_name)
      click_on list_name
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
      list_element = complete ? find_complete_list(list_name) : find_incomplete_list(list_name)
      list_element.find("input").click
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
      find_by_test_id_within(list_element, "pending-list-trash").click
    end

    def complete(list_name)
      list_element = find_incomplete_list(list_name)
      find_by_test_id_within(list_element, "incomplete-list-complete").click
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
      list_element = find_incomplete_list(list_name)
      find_by_test_id_within(list_element, "incomplete-list-edit").click
    end

    def merge(list_name)
      list_element = find_incomplete_list(list_name)
      find_by_test_id_within(list_element, "incomplete-list-merge").click
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
      find_by_test_id_within(list_element, test_id).click
    end

    def refresh_button_css
      "[data-test-id='complete-list-refresh']"
    end

    def refresh(list_name)
      list_element = find_complete_list(list_name)
      find_by_test_id_within(list_element, "complete-list-refresh").click
    end

    def expand_list_form
      find(".btn.btn-link", text: "Add List").click
    end

    def wait_until_log_out_visible
      wait_for { has_test_id?("log-out-link") }
    end

    def wait_until_confirm_delete_button_visible
      wait_for { has_test_id?("confirm-delete") }
    end

    def wait_until_confirm_reject_button_visible
      wait_for { has_test_id?("confirm-reject") }
    end

    def has_merge_warning?
      has_text?("Only lists of the same type can be merged")
    end

    def has_merge_breakdown?
      has_text?("Lists to be merged") && has_text?("Lists excluded")
    end

    def merge_warning_text
      find(".alert-warning").text
    end

    def merge_breakdown_text
      find(".alert-info").text
    end

    def has_clear_merge_button?
      has_test_id?("clear-merge")
    end

    def clear_merge_button
      find_by_test_id("clear-merge")
    end
  end
  # rubocop:enable Metrics/ClassLength
end
