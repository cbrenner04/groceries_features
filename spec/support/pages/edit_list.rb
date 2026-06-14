# frozen_string_literal: true

module Pages
  # edit list form (rendered in the lists-page edit bottom sheet)
  class EditList < SitePrism::Page
    include TestSelectors
    include Helpers::WaitHelper
    include Helpers::ReactInput

    element :name, "#name"
    element :submit, "button[type='submit']", visible: :all

    def enter_name(value)
      wait_for { has_css?("#name", visible: :all, wait: 0) }
      react_fill_in("#name", with: value)
      wait_for { find("#name", visible: :all).value == value }
    end

    def click_submit
      button = find("button[type='submit']", visible: :all)
      page.execute_script("arguments[0].click();", button.native)
    end
  end
end
