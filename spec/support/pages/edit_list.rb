# frozen_string_literal: true

module Pages
  # edit list page
  class EditList < SitePrism::Page
    include TestSelectors
    include Helpers::WaitHelper

    set_url "lists/{id}/edit"

    element :name, "#name"
    element :submit, "[type='submit']"

    def enter_name(value)
      wait_for { has_css?("#name") }
      name.native.clear
      name.send_keys(value)
      wait_for { name.value == value }
    end
  end
end
