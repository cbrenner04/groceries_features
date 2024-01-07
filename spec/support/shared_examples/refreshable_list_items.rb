# frozen_string_literal: true

RSpec.shared_examples "a refreshable list item" do |list_type|
  # ToDoLists complicated the crap out of this which is super unfortunate
  purchased_attr = %w[SimpleList ToDoList].include?(list_type) ? "completed" : "purchased"

  describe "when logged in as the list owner" do
    before do
      login user
      list_page.load(id: list.id)
      @initial_list_item_count = list_page.not_purchased_items.count
    end

    describe "that is purchased" do
      it "is refreshed" do
        item_name = @list_items.last.pretty_title

        list_page.refresh item_name

        wait_for { list_page.not_purchased_items.count == @initial_list_item_count + 1 }

        list_page.close_alert.click
        list_page.filter_button.click
        list_page.filter_option("foo").click

        expect(list_page.not_purchased_items.map(&:text)).to include item_name
      end
    end

    describe "when multiple selected" do
      it "is refreshed" do
        list_page.multi_select_buttons.last.click
        purchased_items = @list_items.filter { |item| item.send(purchased_attr) }
        purchased_items.each { |item| list_page.multi_select_item(item.pretty_title, purchased: true) }
        list_page.refresh(purchased_items.last.pretty_title)

        wait_for { list_page.not_purchased_items.count == 0 }

        expect(list_page.purchased_items.count).to eq 0
        expect(list_page.not_purchased_items.count).to eq 3
      end
    end
  end
end
