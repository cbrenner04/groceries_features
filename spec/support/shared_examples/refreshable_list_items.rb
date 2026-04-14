# frozen_string_literal: true

RSpec.shared_examples "a refreshable list item" do
  describe "when logged in as the list owner" do
    before do
      login user
      list_page.load(id: list.id)
    end

    describe "that is completed" do
      it "is refreshed" do
        initial_list_item_count = list_page.not_completed_items.count
        item_name = @list_items.last.pretty_title

        list_page.refresh item_name

        wait_for { list_page.not_completed_items.count == initial_list_item_count + 1 }

        # list_page.close_alert.click # TODO: not sure why this is no longer working
        list_page.filter_option("foo").click

        wait_for { list_page.list_item_row_matches?(item_name, completed: false) }

        expect(list_page.find_list_item(item_name, completed: false)).to be_visible
      end
    end

    describe "when multiple selected" do
      it "is refreshed" do
        list_to_refresh = @list_items.filter { |item| item.send("completed") }.first.pretty_title

        list_page.multi_select_buttons.last.click
        list_page.multi_select_item(list_to_refresh, completed: true)
        list_page.refresh(list_to_refresh)

        wait_for { list_page.completed_items.none? }
        wait_for { list_page.list_item_row_matches?(list_to_refresh, completed: false) }

        expect(list_page.completed_items.count).to eq 0
        expect(list_page.not_completed_items.count).to eq 3
        expect(list_page.find_list_item(list_to_refresh, completed: false)).to be_visible
      end
    end
  end
end
