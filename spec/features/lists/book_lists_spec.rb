# frozen_string_literal: true

require "spec_helper"

RSpec.describe "A book list" do
  it_behaves_like "a list", "BookList"
end
