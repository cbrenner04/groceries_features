# frozen_string_literal: true

module Pages
  # change other list modal — renders as a bottom sheet
  class ChangeOtherListModal < SitePrism::Page
    include TestSelectors

    element :switch_to_existing_list, "[data-test-id='choose-existing-list-link']"
    element :switch_to_create_list, "[data-test-id='create-new-list-link']"
    element :existing_list_dropdown, "#existingList"
    element :new_list_name_input, "#newListName"
    element :complete, :button, text: "Complete"
    element :cancel, :button, text: "Cancel"
    element :modal_container, "[data-test-id='change-other-list-modal']"

    def has_modal?
      has_test_id?("change-other-list-modal")
    end

    def has_no_modal?
      has_no_test_id?("change-other-list-modal")
    end
  end
end
