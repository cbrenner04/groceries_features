# frozen_string_literal: true

module Models
  # an item on a music list
  class MusicListItem
    attr_reader :id, :user_id, :music_list_id, :title, :artist,
                :album, :purchased

    def initialize(user_id:, music_list_id:, purchased: false,
                   create_item: true)
      @user_id = user_id
      @music_list_id = music_list_id
      @title = SecureRandom.hex(16)
      @artist = SecureRandom.hex(16)
      @album = SecureRandom.hex(8)
      @purchased = purchased
      @id = create if create_item
    end

    private

    def create
      DB[:music_list_items].insert(
        user_id: user_id, music_list_id: music_list_id, title: title,
        artist: artist, album: album, purchased: purchased,
        created_at: Time.now, updated_at: Time.now
      )
    end
  end
end
