# frozen_string_literal: true

module Pages
  # edit list page
  class List < SitePrism::Page
    NOT_PURCHASED_ITEM = "div[data-test-class='non-purchased-item']"
    PURCHASED_ITEM = "div[data-test-class='purchased-item']"
    UNREAD_BUTTON = '.fa.fa-bookmark-o'
    READ_BUTTON = '.fa.fa-bookmark'
    PURCHASE_BUTTON = '.fa.fa-check-square-o'
    EDIT_BUTTON = '.fa.fa-pencil-square-o'
    DELETE_BUTTON = '.fa.fa-trash'
    REFRESH_BUTTON = '.fa.fa-refresh'

    set_url '/lists/{id}'

    elements :not_purchased_items, NOT_PURCHASED_ITEM
    elements :purchased_items, PURCHASED_ITEM

    element :item_deleted_alert,
            '.alert',
            text: 'Your item was successfully deleted'
    element :author, "input[name='author']"
    element :title, "input[name='title']"
    element :quantity, "input[name='quantity']"
    element :quantity_name, "input[name='quantityName']"
    element :artist, "input[name='artist']"
    element :album, "input[name='album']"
    element :name, "input[name='itemName']"
    element :submit, "button[type='submit']"

    def read(item_name, purchased: false)
      item_css = purchased ? PURCHASED_ITEM : NOT_PURCHASED_ITEM
      find(item_css, text: item_name).find(UNREAD_BUTTON).click
    end

    def has_read_item?(item_name, purchased: false)
      item_css = purchased ? PURCHASED_ITEM : NOT_PURCHASED_ITEM
      item = find(item_css, text: item_name)
      item.has_css?(READ_BUTTON) && item.has_no_css?(UNREAD_BUTTON)
    end

    def purchase(item_name)
      find(NOT_PURCHASED_ITEM, text: item_name).find(PURCHASE_BUTTON).click
    end

    def edit(item_name)
      find(NOT_PURCHASED_ITEM, text: item_name).find(EDIT_BUTTON).click
    end

    def delete(item_name, purchased: false)
      list_css = purchased ? PURCHASED_ITEM : NOT_PURCHASED_ITEM
      find(list_css, text: item_name).find(DELETE_BUTTON).click
    end

    def refresh(item_name)
      find(PURCHASED_ITEM, text: item_name).find(REFRESH_BUTTON).click
    end
  end
end
