# frozen_string_literal: true

module Pages
  # edit list page
  class EditList < SitePrism::Page
    include TestSelectors

    set_url "/lists/{id}/edit"

    def name
      find_by_test_id("list-name-input")
    end

    def submit
      find_by_test_id("edit-list-submit")
    end

    # has_*? methods for elements that use data-test-* selectors
    def has_name?
      has_test_id?("list-name-input")
    end

    def has_submit?
      has_test_id?("edit-list-submit")
    end

    # has_no_*? methods for negative assertions
    def has_no_name?
      has_no_test_id?("list-name-input")
    end

    def has_no_submit?
      has_no_test_id?("edit-list-submit")
    end
  end
end
