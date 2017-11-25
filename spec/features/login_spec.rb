# frozen_string_literal: true

require 'spec_helper'

RSpec.feature 'Login' do
  let(:test_user) { Models::User.new }

  it 'logs in successfully' do
    login test_user
    expect(home_page).to be_displayed
  end
end
