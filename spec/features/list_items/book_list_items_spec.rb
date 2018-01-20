# frozen_string_literal: true

require 'spec_helper'

RSpec.feature 'A book list item' do
  let(:list_page) { Pages::List.new }
  let(:edit_list_item_page) { Pages::EditListItem.new }
  let(:user) { Models::User.new }
  let(:list) { Models::List.new(type: 'BookList') }

  before do
    @list_items = create_associated_list_objects(user, list)

    login user
    list_page.load(id: list.id)
  end

  it 'is created' do
    new_list_item = Models::BookListItem.new(user_id: user.id,
                                             book_list_id: list.id,
                                             create_item: false)

    list_page.author.set new_list_item.author
    list_page.title.set new_list_item.title
    list_page.submit.click

    wait_for do
      list_page.not_purchased_items.count == 2
    end

    expect(list_page.not_purchased_items.map(&:text))
      .to include new_list_item.pretty_title
  end

  describe 'that is not purchased' do
    it 'is read' do
      item_name = @list_items.first.pretty_title

      list_page.read item_name

      list_page.wait_for_not_purchased_items
      expect(list_page).to have_read_item item_name
    end

    it 'is purchased' do
      item_name = @list_items.first.pretty_title

      list_page.purchase item_name

      wait_for do
        list_page.purchased_items.count == 2
      end

      expect(list_page.purchased_items.map(&:text)).to include item_name
    end

    it 'is edited' do
      item = @list_items.first

      list_page.edit item.pretty_title

      item.title = SecureRandom.hex(16)

      wait_for do
        edit_list_item_page.title.set item.title
        edit_list_item_page.title.value == item.title
      end

      edit_list_item_page.submit.click

      list_page.wait_for_not_purchased_items
      expect(list_page.not_purchased_items.map(&:text))
        .to include item.pretty_title
    end

    it 'is destroyed' do
      item_name = @list_items.first.pretty_title

      list_page.accept_alert do
        list_page.delete item_name
      end

      list_page.wait_for_not_purchased_items
      expect(list_page.not_purchased_items.map(&:text)).to_not include item_name
    end
  end

  describe 'that is purchased' do
    it 'is read' do
      item_name = @list_items.last.pretty_title

      list_page.read item_name, purchased: true

      list_page.wait_for_purchased_items
      expect(list_page).to have_read_item item_name, purchased: true
    end

    it 'is destroyed' do
      item_name = @list_items.last.pretty_title

      list_page.accept_alert do
        list_page.delete item_name, purchased: true
      end

      wait_for do
        list_page.purchased_items.count.zero?
      end

      expect(list_page.purchased_items.map(&:text)).to_not include item_name
    end
  end
end
