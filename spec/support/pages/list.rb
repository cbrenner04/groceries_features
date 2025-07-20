# frozen_string_literal: true

module Pages
  # list page
  class List < SitePrism::Page
    include TestSelectors
    include Helpers::WaitHelper

    UNREAD_BUTTON = ".far.fa-bookmark"
    READ_BUTTON = ".fas.fa-bookmark"
    COMPLETE_BUTTON = ".fa.fa-check"
    EDIT_BUTTON = ".fa.fa-edit"
    DELETE_BUTTON = ".fa.fa-trash"
    REFRESH_BUTTON = ".fa.fa-redo"

    set_url "/lists/{id}"

    element :item_deleted_alert, "[role='alert']", text: "Item successfully deleted."
    element :author_input, "#author"
    element :title_input, "#title"
    element :number_in_series_input, "#number_in_series"
    element :category_input, "#category"
    element :quantity_input, "#quantity"
    element :artist_input, "#artist"
    element :album_input, "#album"
    element :task_input, "#task"
    element :assignee_input, "#assignee_email"
    element :due_by_input, "#due_by"
    element :content_input, "#content"
    element :product_input, "#product"
    element :submit_button, "button[type='submit']"
    element :filter_button, "#filter-by-category-button"

    element :close_alert, ".Toastify__close-button.Toastify__close-button--colored"
    elements :multi_select_buttons, :button, "Select"
    element :copy_to_list, :button, text: "Copy to list"
    element :move_to_list, :button, text: "Move to list"

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

    def unread_button_css
      UNREAD_BUTTON
    end

    def complete_button_css
      COMPLETE_BUTTON
    end

    def edit_button_css
      EDIT_BUTTON
    end

    def delete_button_css
      DELETE_BUTTON
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

    def find_list_item(item_name, completed: false)
      test_class = completed ? "completed-item" : "non-completed-item"
      find_by_test_class(test_class, text: item_name)
    end

    def read(item_name, completed: false)
      item_element = find_list_item(item_name, completed:)
      item_element.find(UNREAD_BUTTON).click
    end

    def has_read_item?(item_name, completed: false)
      item = find_list_item(item_name, completed:)
      item.has_css?(READ_BUTTON) && item.has_no_css?(UNREAD_BUTTON)
    end

    def complete(item_name)
      item_element = find_list_item(item_name, completed: false)
      item_element.find(COMPLETE_BUTTON).click
    end

    def edit(item_name)
      item_element = find_list_item(item_name, completed: false)
      item_element.find(EDIT_BUTTON).click
    end

    def delete(item_name, completed: false)
      item_element = find_list_item(item_name, completed:)
      item_element.find(DELETE_BUTTON).click
    end

    def refresh(item_name)
      item_element = find_list_item(item_name, completed: true)
      item_element.find(REFRESH_BUTTON).click
    end

    def expand_list_item_form
      find(".btn.btn-link", text: "Add Item").click
    end

    def multi_select_item(item_name, completed: false)
      item_element = find_list_item(item_name, completed:)
      item_element.find("input").click
    end

    def wait_until_confirm_delete_button_visible
      wait_for { has_test_id?("confirm-delete") }
    end

    def wait_until_completed_items_visible
      wait_for { has_test_class?("completed-item") }
    end

    def wait_until_not_completed_items_visible
      wait_for { has_test_class?("non-completed-item") }
    end
  end
end
