# frozen_string_literal: true

module Pages
  # completed lists page, displays users completed lists
  class CompletedLists < SitePrism::Page
    COMPLETE_LIST = "div[data-test-class='completed-list']"
    DELETE_BUTTON = '.fa.fa-trash'
    REFRESH_BUTTON = '.fa.fa-refresh'

    def delete_button_css
      DELETE_BUTTON
    end

    def find_complete_list(list_name)
      find(COMPLETE_LIST, text: list_name)
    end

    def refresh_button_css
      REFRESH_BUTTON
    end
  end
end
