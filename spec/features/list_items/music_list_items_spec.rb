# frozen_string_literal: true

require 'spec_helper'

RSpec.feature 'A music list item' do
  it 'is created'

  describe 'that is not purchased' do
    it 'is purchased'
    it 'is edited'
    it 'is destroyed'
  end

  describe 'that is purchased' do
    it 'is destroyed'
  end
end
