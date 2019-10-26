# frozen_string_literal: true

module Pages
  # completed lists page, displays users completed lists
  class CompletedLists < SitePrism::Page
    COMPLETE_LIST = "div[data-test-class='completed-list']"
    DELETE_BUTTON = '.fa.fa-trash'
    REFRESH_BUTTON = '.fa.fa-refresh'

    elements :complete_list_names, "#{COMPLETE_LIST} h5"

    def delete(list_name)
      find_complete_list(list_name).find(DELETE_BUTTON).click
    end

    def delete_button_css
      DELETE_BUTTON
    end

    def find_complete_list(list_name)
      find(COMPLETE_LIST, text: list_name)
    end

    def refresh_button_css
      REFRESH_BUTTON
    end

    def refresh(list_name)
      find_complete_list(list_name).find(REFRESH_BUTTON).click
    end
  end
end
