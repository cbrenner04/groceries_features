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

        list_page.close_alert.click
        list_page.filter_button.click
        list_page.filter_option("foo").click

        expect(list_page.not_completed_items.map(&:text)).to include item_name
      end
    end

    describe "when multiple selected" do
      it "is refreshed" do
        list_to_refresh = @list_items.filter { |item| item.send("completed") }.first.pretty_title

        list_page.multi_select_buttons.last.click
        list_page.multi_select_item(list_to_refresh, completed: true)
        list_page.refresh(list_to_refresh)

        wait_for { list_page.completed_items.none? }
        wait_for { list_page.not_completed_items.map(&:text).include?(list_to_refresh) }

        expect(list_page.completed_items.count).to eq 0
        expect(list_page.not_completed_items.count).to eq 3
        expect(list_page.not_completed_items.map(&:text)).to include list_to_refresh
      end
    end
  end
end
