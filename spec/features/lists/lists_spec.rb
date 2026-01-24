# frozen_string_literal: true

require "spec_helper"

RSpec.describe "A list", type: :feature do
  it_behaves_like "a list", "grocery list template"
end
