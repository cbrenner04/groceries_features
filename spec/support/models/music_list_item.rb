# frozen_string_literal: true

module Models
  # an item on a music list
  class MusicListItem
    attr_accessor :title
    attr_reader :id, :user_id, :list_id, :artist, :album, :purchased, :category

    def initialize(user_id:, list_id:, purchased: false, category: nil, create_item: true)
      @user_id = user_id
      @list_id = list_id
      @title = SecureRandom.hex(16)
      @artist = SecureRandom.hex(16)
      @album = SecureRandom.hex(8)
      @purchased = purchased
      @category = category
      @id = create if create_item
    end

    def pretty_title
      "\"#{title}\" #{artist} - #{album}"
    end

    private

    def create
      DB[:music_list_items].insert(user_id:, list_id:, title:, artist:,
                                   album:, purchased:, created_at: Time.now, updated_at: Time.now,
                                   category:)
    end
  end
end
