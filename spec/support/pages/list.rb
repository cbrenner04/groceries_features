# frozen_string_literal: true

module Pages
  # list page
  class List < SitePrism::Page
    include TestSelectors
    include Helpers::WaitHelper

    COMPLETE_BUTTON = "[data-test-id^='not-completed-item-complete-']"

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
      "[data-test-id^='not-completed-item-edit-']"
    end

    def delete_button_css
      "[data-test-id^='not-completed-item-delete-'], [data-test-id^='completed-item-delete-']"
    end

    def refresh_button_css
      "[data-test-id^='completed-item-refresh-']"
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

    # Split pretty_title on newlines and middle dots so row text matches ListItemRow
    # (secondary values are joined with " · " regardless of field order).
    def list_item_name_tokens(item_name)
      raw = item_name.to_s.split(/[\n\u{00b7}]/).map(&:strip).reject(&:empty?)
      # Due dates: Ruby strftime and client prettyDueBy/locale can differ — omit date-only tokens.
      raw.grep_v(/\A[A-Za-z]+\s+\d{1,2},\s+\d{4}\z/)
    end

    def list_item_row_matches?(item_name, completed: false)
      test_class = completed ? "completed-item" : "non-completed-item"
      parts = list_item_name_tokens(item_name)
      return false if parts.empty?

      all(:css, "[data-test-class='#{test_class}']").any? do |el|
        text = el.text.downcase
        parts.all? { |p| text.include?(p.downcase) }
      end
    end

    # Row text order can differ from legacy pretty_title newlines; match every segment.
    def find_list_item(item_name, completed: false)
      test_class = completed ? "completed-item" : "non-completed-item"
      parts = list_item_name_tokens(item_name)
      raise ArgumentError, "find_list_item requires at least one text segment" if parts.empty?

      result = nil
      wait_for do
        result = all(:css, "[data-test-class='#{test_class}']").find do |el|
          text = el.text.downcase
          parts.all? { |p| text.include?(p.downcase) }
        end
        result
      end
      result
    end

    def complete(item_name)
      item_element = find_list_item(item_name, completed: false)
      item_element.find(:css, COMPLETE_BUTTON).click
    end

    def edit(item_name)
      item_element = find_list_item(item_name, completed: false)
      item_element.find(:css, "[data-test-id^='not-completed-item-edit-']").click
    end

    def delete(item_name, completed: false)
      item_element = find_list_item(item_name, completed:)
      selector =
        completed ? "[data-test-id^='completed-item-delete-']" : "[data-test-id^='not-completed-item-delete-']"
      item_element.find(:css, selector).click
    end

    def refresh(item_name)
      item_element = find_list_item(item_name, completed: true)
      item_element.find(:css, "[data-test-id^='completed-item-refresh-']").click
    end

    def expand_list_item_form
      find_by_test_id("quick-add-expand").click
    end

    def multi_select_item(item_name, completed: false)
      item_element = find_list_item(item_name, completed:)
      item_element.find("input").click
    end

    def toggle_multi_select
      find_by_test_id("select-button").click
    end

    def edit_item_via_sheet(item_name)
      item_element = find_list_item(item_name, completed: false)
      item_element.find(:css, "[data-test-id^='not-completed-item-edit-']").click
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
      wait_for { has_test_id?("confirm-delete") }
    end

    def wait_until_completed_items_visible
      wait_for { has_test_class?("completed-item") }
    end

    def wait_until_not_completed_items_visible
      wait_for { has_test_class?("non-completed-item") }
    end

    def submit_add_item
      form = find(:css, "[data-test-id='list-item-form']", match: :first)
      page.execute_script("arguments[0].requestSubmit();", form.native)
    end
  end
end
