# frozen_string_literal: true

module Pages
  # list page
  class List < SitePrism::Page
    include TestSelectors
    include Helpers::WaitHelper

    COMPLETE_BUTTON = "[data-test-id^='not-completed-item-complete-']"
    EDIT_BUTTON = "[data-test-id^='not-completed-item-edit-']"
    NOT_COMPLETED_DELETE_BUTTON = "[data-test-id^='not-completed-item-delete-']"
    COMPLETED_DELETE_BUTTON = "[data-test-id^='completed-item-delete-']"
    REFRESH_BUTTON = "[data-test-id^='completed-item-refresh-']"

    set_url "lists/{id}"

    element :item_deleted_alert, "[role='alert']", text: "Item successfully deleted."
    element :author_input, "#author"
    element :title_input, "#title"
    element :number_in_series_input, "#number\\ in\\ series"
    element :category_input, "#category"
    element :quantity_input, "#quantity"
    element :artist_input, "#artist"
    element :album_input, "#album"
    element :task_input, "#task"
    element :assignee_input, "#assignee"
    element :due_by_input, "#due\\ by"
    element :content_input, "#content"
    element :product_input, "#product"
    element :completed_checkbox, "#completed"
    element :submit_button, "button[type='submit']"
    element :close_alert, ".Toastify__close-button.Toastify__close-button--colored"
    element :select_button, "[data-test-id='select-button']"
    element :multi_select_bar, "[data-test-id='multi-select-bar']"
    elements :multi_select_buttons, "[data-test-id='select-button']"
    element :copy_to_list, "[data-test-id='copy-to-list']"
    element :move_to_list, "[data-test-id='move-to-list']"

    # has_*? methods for elements that use data-test-* selectors
    def has_filter_option?(filter_name)
      has_test_id?("filter-by-#{filter_name}")
    end

    def has_clear_filter?
      has_test_id?("clear-filter")
    end

    def has_confirm_delete?
      has_test_id?("confirm-delete")
    end

    def has_not_completed_items?
      has_test_class?("non-completed-item")
    end

    def has_completed_items?
      has_test_class?("completed-item")
    end

    def has_category_header?
      has_test_class?("category-header")
    end

    # has_no_*? methods for negative assertions
    def has_no_filter_option?(filter_name)
      has_no_test_id?("filter-by-#{filter_name}")
    end

    def has_no_clear_filter?
      has_no_test_id?("clear-filter")
    end

    def has_no_confirm_delete?
      has_no_test_id?("confirm-delete")
    end

    def has_no_not_completed_items?
      has_no_test_class?("non-completed-item")
    end

    def has_no_completed_items?
      has_no_test_class?("completed-item")
    end

    def has_no_category_header?
      has_no_test_class?("category-header")
    end

    def complete_button_css
      COMPLETE_BUTTON
    end

    def edit_button_css
      EDIT_BUTTON
    end

    def not_completed_delete_button_css
      NOT_COMPLETED_DELETE_BUTTON
    end

    def completed_delete_button_css
      COMPLETED_DELETE_BUTTON
    end

    def delete_button_css
      NOT_COMPLETED_DELETE_BUTTON
    end

    def refresh_button_css
      REFRESH_BUTTON
    end

    def filter_option(filter_name)
      find_by_test_id("filter-by-#{filter_name}")
    end

    def clear_filter_button
      find_by_test_id("clear-filter")
    end

    def confirm_delete_button
      find_by_test_id("confirm-delete")
    end

    def not_completed_items
      all_by_test_class("non-completed-item")
    end

    def completed_items
      all_by_test_class("completed-item")
    end

    def category_header
      all_by_test_class("category-header")
    end

    # Each row exposes data-test-id="list-item-<id>" plus a data-test-class for its completed
    # state, so an item is located directly by its id rather than matching on rendered text.
    def find_list_item(item, completed: false)
      find(:css, list_item_selector(item, completed:))
    end

    def has_list_item?(item, completed: false)
      has_css?(list_item_selector(item, completed:))
    end

    def has_no_list_item?(item, completed: false)
      has_no_css?(list_item_selector(item, completed:))
    end

    def complete(item)
      item_element = find_list_item(item, completed: false)
      item_element.find(:css, COMPLETE_BUTTON).click
    end

    def edit(item)
      item_element = find_list_item(item, completed: false)
      item_element.find(:css, EDIT_BUTTON).click
    end

    def delete(item, completed: false)
      item_element = find_list_item(item, completed:)
      selector = completed ? COMPLETED_DELETE_BUTTON : NOT_COMPLETED_DELETE_BUTTON
      item_element.find(:css, selector).click
    end

    def refresh(item)
      item_element = find_list_item(item, completed: true)
      item_element.find(:css, REFRESH_BUTTON).click
    end

    def expand_list_item_form
      find_by_test_id("quick-add-expand").click
    end

    def multi_select_item(item, completed: false)
      item_element = find_list_item(item, completed:)
      item_element.find("input").click
    end

    def toggle_multi_select
      find_by_test_id("select-button").click
    end

    def edit_item_via_sheet(item)
      item_element = find_list_item(item, completed: false)
      item_element.find(:css, EDIT_BUTTON).click
      wait_for { has_test_id?("edit-item-sheet") }
    end

    def copy_to_list_button
      find_by_test_id("copy-to-list")
    end

    def move_to_list_button
      find_by_test_id("move-to-list")
    end

    def bulk_edit_button
      find_by_test_id("bulk-edit")
    end

    def complete_selected_button
      find_by_test_id("complete-selected")
    end

    def delete_selected_button
      find_by_test_id("delete-selected")
    end

    def refresh_selected_button
      find_by_test_id("refresh-selected")
    end

    def has_multi_select_bar?
      has_test_id?("multi-select-bar")
    end

    def has_no_multi_select_bar?
      has_no_test_id?("multi-select-bar")
    end

    def quick_add_input
      find_by_test_id("quick-add-input")
    end

    def wait_until_confirm_delete_button_visible
      wait_for { has_css?("[data-test-id='confirm-delete']:not([disabled])") }
    end

    def wait_until_completed_items_visible
      wait_for { has_css?("[data-test-class='completed-item']", visible: :all) }
    end

    def wait_until_not_completed_items_visible
      wait_for { has_css?("[data-test-class='non-completed-item']", visible: :all) }
    end

    def submit_add_item
      submit_button.click
    end

    private

    def list_item_selector(item, completed:)
      status_class = completed ? "completed-item" : "non-completed-item"
      item_id = item.respond_to?(:id) ? item.id : item
      "[data-test-class='#{status_class}'][data-test-id='list-item-#{item_id}']"
    end
  end
end
