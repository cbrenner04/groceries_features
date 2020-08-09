# frozen_string_literal: true

require "spec_helper"

RSpec.describe "A to do list", type: :feature do
  it_behaves_like "a list", "ToDoList"
end
