# frozen_string_literal: true

require "spec_helper"

RSpec.describe "A music list", type: :feature do
  it_behaves_like "a list", "MusicList"
end
