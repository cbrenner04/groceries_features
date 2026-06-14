# frozen_string_literal: true

module Pages
  # copy/move UI — BottomSheet (`change-other-list-sheet`) or legacy Modal (`change-other-list-modal`)
  class ChangeOtherListModal < SitePrism::Page
    include TestSelectors
    include Helpers::WaitHelper

    COPY_MOVE_ROOT = "[data-test-id='change-other-list-sheet'], [data-test-id='change-other-list-modal']"

    element :switch_to_existing_list, "[data-test-id='choose-existing-list-link']"
    element :switch_to_create_list, "[data-test-id='create-new-list-link']"
    element :existing_list_dropdown, "#existingList"
    element :new_list_name_input, "#newListName"
    element :complete, :button, text: "Complete"
    element :cancel, :button, text: "Cancel"
    element :modal_container, "[data-test-id='change-other-list-modal']"

    def has_modal?
      has_css?(COPY_MOVE_ROOT)
    end

    def has_no_modal?
      has_no_css?(COPY_MOVE_ROOT)
    end

    def wait_until_new_list_name_input_visible
      wait_for { has_modal? }
      wait_for { has_css?("#{COPY_MOVE_ROOT} #newListName") }
    end

    def all_links
      find(:css, COPY_MOVE_ROOT, match: :first).all(:link)
    rescue Capybara::ElementNotFound
      []
    end

    # Fixed BottomInputBar can intercept native clicks on sheet actions.
    def click_complete
      wait_for { has_modal? }
      root = find(:css, COPY_MOVE_ROOT, match: :first)
      within(root) do
        btn = first(:button, text: "Complete")
        page.execute_script("arguments[0].click();", btn.native)
      end
    end
  end
end
