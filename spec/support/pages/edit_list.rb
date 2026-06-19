# frozen_string_literal: true

module Pages
  # edit list form (rendered in the lists-page edit bottom sheet)
  class EditList < SitePrism::Page
    include TestSelectors
    include Helpers::WaitHelper

    element :name, "#name"
    element :submit, "button[type='submit']", visible: :all
  end
end
