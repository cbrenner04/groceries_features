# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Templates", type: :feature do
  let(:user) { Models::User.new }
  let(:home_page) { Pages::Home.new }
  let(:templates_page) { Pages::Templates.new }
  let(:edit_template_page) { Pages::EditTemplate.new }

  before { login user }

  describe "navigating to templates" do
    it "navigates from lists page via Manage Templates link" do
      templates_page.manage_templates
      expect(templates_page).to have_header
    end
  end

  describe "viewing templates" do
    it "displays the user's default templates" do
      templates_page.load
      expect(templates_page).to have_templates
      expect(templates_page.template_names).to include("grocery list template")
    end
  end

  describe "creating a template" do
    it "creates a new template with fields" do
      templates_page.load
      templates_page.expand_template_form
      templates_page.template_name_input.set("my custom template")

      # First field row should already exist with primary checked
      templates_page.field_label_input(0).set("item name")
      templates_page.field_data_type_select(0).select("Free Text")

      # Add a second field
      templates_page.add_field_button.click
      templates_page.field_label_input(1).set("quantity")
      templates_page.field_data_type_select(1).select("Number")

      templates_page.submit.click

      wait_for { templates_page.template_names.include?("my custom template") }

      expect(templates_page.template_names).to include("my custom template")
    end

    context "with validation errors" do
      it "shows error when name is blank" do
        templates_page.load
        templates_page.expand_template_form
        # Leave name blank, try to submit
        templates_page.field_label_input(0).set("item name")
        
        expect(templates_page.submit).to be_disabled
      end
    end
  end

  describe "editing a template" do
    it "updates template name" do
      templates_page.load
      original_name = templates_page.template_names.first
      templates_page.edit(original_name)

      expect(edit_template_page).to have_header

      edit_template_page.template_name_input.native.clear
      edit_template_page.template_name_input.set("updated template name")
      edit_template_page.submit.click

      expect(templates_page).to have_header
      expect(templates_page.template_names).to include("updated template name")
    end

    it "adds a new field to an existing template" do
      templates_page.load
      template_name = templates_page.template_names.first
      templates_page.edit(template_name)

      initial_field_count = edit_template_page.field_rows.count

      edit_template_page.add_field_button.click
      new_index = initial_field_count

      edit_template_page.field_label_input(new_index).set("new field")
      edit_template_page.field_data_type_select(new_index).select("Boolean")
      edit_template_page.submit.click

      expect(templates_page).to have_header
    end

    it "removes a field from an existing template" do
      templates_page.load
      template_name = templates_page.template_names.first
      templates_page.edit(template_name)

      # Only remove if there are at least 2 non-primary fields
      initial_count = edit_template_page.field_rows.count
      if initial_count > 1
        edit_template_page.remove_field_button(initial_count - 1).click
        edit_template_page.submit.click
        expect(templates_page).to have_header
      end
    end
  end

  describe "deleting a template" do
    it "deletes a template that is not in use" do
      # Create a template specifically for deletion
      templates_page.load
      templates_page.expand_template_form
      templates_page.template_name_input.set("template to delete")
      templates_page.field_label_input(0).set("disposable field")
      templates_page.submit.click

      wait_for { templates_page.template_names.include?("template to delete") }

      templates_page.delete("template to delete")
      templates_page.wait_until_confirm_delete_button_visible
      templates_page.confirm_delete_button.click

      wait_for { !templates_page.template_names.include?("template to delete") }

      expect(templates_page.template_names).not_to include("template to delete")
    end
  end

  describe "template appears in list creation dropdown" do
    it "shows newly created template when creating a list" do
      templates_page.load
      templates_page.expand_template_form
      templates_page.template_name_input.set("brand new template")
      templates_page.field_label_input(0).set("primary field")
      templates_page.submit.click

      # Navigate to lists page
      home_page.load
      home_page.expand_list_form

      template_options = home_page.list_template.all("option").map(&:text)
      expect(template_options).to include("brand new template")
    end
  end
end
