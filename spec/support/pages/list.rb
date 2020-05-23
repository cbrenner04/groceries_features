# frozen_string_literal: true

module Pages
  # edit list page
  class List < SitePrism::Page
    NOT_PURCHASED_ITEM = "div[data-test-class='non-purchased-item']"
    PURCHASED_ITEM = "div[data-test-class='purchased-item']"
    UNREAD_BUTTON = '.far.fa-bookmark'
    READ_BUTTON = '.fas.fa-bookmark'
    PURCHASE_BUTTON = '.fa.fa-check'
    EDIT_BUTTON = '.fa.fa-edit'
    DELETE_BUTTON = '.fa.fa-trash'
    REFRESH_BUTTON = '.fa.fa-redo'

    set_url '/lists/{id}'

    elements :not_purchased_items, NOT_PURCHASED_ITEM
    elements :purchased_items, PURCHASED_ITEM

    element :item_deleted_alert,
            '.Toastify',
            text: 'Item successfully deleted.'
    element :author_input, '#author'
    element :title_input, '#title'
    element :number_in_series_input, '#numberInSeries'
    element :category_input, '#category'
    element :quantity_input, '#quantity'
    element :artist_input, '#artist'
    element :album_input, '#album'
    element :task_input, '#task'
    element :product_input, '#product'
    element :submit_button, "button[type='submit']"
    element :category_header, "h5[data-test-class='category-header']"
    element :filter_button, '#filter-by-category-button'
    element :clear_filter_button, '#clear-filter-button'
    element :confirm_delete_button, 'button[data-test-id="confirm-delete"]'

    def unread_button_css
      UNREAD_BUTTON
    end

    def purchase_button_css
      PURCHASE_BUTTON
    end

    def edit_button_css
      EDIT_BUTTON
    end

    def delete_button_css
      DELETE_BUTTON
    end

    def not_purchased_item_css
      NOT_PURCHASED_ITEM
    end

    def purchased_item_css
      PURCHASED_ITEM
    end

    def refresh_button_css
      REFRESH_BUTTON
    end

    def filter_option(filter_name)
      find("button[name='#{filter_name}']")
    end

    def find_list_item(item_name, purchased: false)
      item_css = purchased ? PURCHASED_ITEM : NOT_PURCHASED_ITEM
      find(item_css, text: item_name)
    end

    def read(item_name, purchased: false)
      item_css = purchased ? PURCHASED_ITEM : NOT_PURCHASED_ITEM
      find(item_css, text: item_name).find(UNREAD_BUTTON).click
    end

    def has_read_item?(item_name, purchased: false)
      item = find_list_item(item_name, purchased: purchased)
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
