# frozen_string_literal: true

module Pages
  # app home page, displayed after log in, displays lists
  # rubocop:disable Metrics/ClassLength
  class Home < SitePrism::Page
    COMPLETE_LIST = "div[data-test-class='completed-list']"
    INCOMPLETE_LIST = "div[data-test-class='incomplete-list']"
    PENDING_LIST = "div[data-test-class='pending-list']"
    COMPLETE_BUTTON = 'button[data-test-id="incomplete-list-complete"]'
    INCOMPLETE_DELETE_BUTTON = 'button[data-test-id="incomplete-list-trash"]'
    COMPLETE_DELETE_BUTTON = 'button[data-test-id="complete-list-trash"]'
    SHARE_BUTTON = 'a[data-test-id="incomplete-list-share"]'
    EDIT_BUTTON = 'a[data-test-id="incomplete-list-edit"]'
    REFRESH_BUTTON = 'button[data-test-id="complete-list-refresh"]'
    ACCEPT_BUTTON = 'button[data-test-id="pending-list-accept"]'
    REJECT_BUTTON = 'button[data-test-id="pending-list-trash"]'
    MERGE_BUTTON = 'button[data-test-id="incomplete-list-merge"]'

    set_url "/"

    element :signed_in_alert, ".Toastify", text: "Signed in successfully"
    element :list_deleted_alert, ".Toastify", text: "List successfully deleted."
    element :list_type, "#type"
    element :header, "h1", text: "Lists"
    element :name, "#name"
    element :submit, "button[type='submit']"
    element :invite, 'a[data-test-id="invite-link"]'
    element :log_out, 'a[data-test-id="log-out-link"]'
    element :complete_button, COMPLETE_BUTTON
    element :incomplete_delete_button, INCOMPLETE_DELETE_BUTTON
    element :share_button, SHARE_BUTTON
    element :edit_button, EDIT_BUTTON
    element :refresh_button, REFRESH_BUTTON
    element :merge_button, MERGE_BUTTON
    element :new_merged_list_name_input, "#mergeName"

    elements :complete_lists, COMPLETE_LIST
    elements :complete_list_names, "#{COMPLETE_LIST} h5"
    elements :incomplete_lists, INCOMPLETE_LIST
    elements :incomplete_list_names, "#{INCOMPLETE_LIST} h5"
    elements :pending_list_names, "#{PENDING_LIST} h5"
    element :confirm_delete_button, 'button[data-test-id="confirm-delete"]'
    element :confirm_reject_button, 'button[data-test-id="confirm-reject"]'
    element :confirm_merge_button, 'button[data-test-id="confirm-merge"]'
    elements :multi_select_buttons, :button, "Select"

    def go_to_completed_lists
      click_on "See all completed lists here"
    end

    def select_list(list_name)
      click_on list_name
    end

    def find_pending_list(list_name)
      find(PENDING_LIST, text: list_name)
    end

    def find_incomplete_list(list_name)
      find(INCOMPLETE_LIST, text: list_name)
    end

    def find_complete_list(list_name)
      find(COMPLETE_LIST, text: list_name)
    end

    def accept_button_css
      ACCEPT_BUTTON
    end

    def complete_button_css
      COMPLETE_BUTTON
    end

    def reject_button_css
      REJECT_BUTTON
    end

    def incomplete_delete_button_css
      INCOMPLETE_DELETE_BUTTON
    end

    def complete_delete_button_css
      COMPLETE_DELETE_BUTTON
    end

    def edit_button_css
      EDIT_BUTTON
    end

    def share_button_css
      SHARE_BUTTON
    end

    def refresh_button_css
      REFRESH_BUTTON
    end

    def multi_select_list(list_name, complete: false)
      list_css = complete ? COMPLETE_LIST : INCOMPLETE_LIST
      find(list_css, text: list_name).find("input").click
    end

    def accept(list_name)
      find_pending_list(list_name).find(ACCEPT_BUTTON).click
    end

    def reject(list_name)
      find_pending_list(list_name).find(REJECT_BUTTON).click
    end

    def complete(list_name)
      find_incomplete_list(list_name).find(COMPLETE_BUTTON).click
    end

    def share(list_name)
      find_incomplete_list(list_name).find(SHARE_BUTTON).click
    end

    def edit(list_name)
      find_incomplete_list(list_name).find(EDIT_BUTTON).click
    end

    def merge(list_name)
      find_incomplete_list(list_name).find(MERGE_BUTTON).click
    end

    def delete(list_name, complete: false)
      list_css = complete ? COMPLETE_LIST : INCOMPLETE_LIST
      button_css = complete ? COMPLETE_DELETE_BUTTON : INCOMPLETE_DELETE_BUTTON
      find(list_css, text: list_name).find(button_css).click
    end

    def refresh(list_name)
      find_complete_list(list_name).find(REFRESH_BUTTON).click
    end

    def expand_list_form
      find(".btn.btn-link", text: "Add List").click
    end
  end
  # rubocop:enable Metrics/ClassLength
end
