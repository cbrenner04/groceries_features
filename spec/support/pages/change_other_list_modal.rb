# frozen_string_literal: true

module Pages
  # edit list page
  class ChangeOtherListModal < SitePrism::Page
    element :switch_to_existing_list, :button, text: "Choose existing list"
    element :switch_to_create_list, :button, text: "Create new list"
    element :existing_list_dropdown, "#existingList"
    element :new_list_name_input, "#newListName"
    element :complete, :button, text: "Complete"
    element :cancel, :button, text: "Cancel"

    def all_links
      find_all(".btn.btn-link")
    end
  end
end
