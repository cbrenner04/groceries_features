# frozen_string_literal: true

module Pages
  # edit list page
  class List < SitePrism::Page
    NOT_PURCHASED_ITEM = "div[data-test-class='non-purchased-item']"
    PURCHASED_ITEM = "div[data-test-class='purchased-item']"

    set_url '/lists/{id}'

    elements :not_purchased_items, NOT_PURCHASED_ITEM
    elements :purchased_items, PURCHASED_ITEM
  end
end
