# frozen_string_literal: true

module Models
  # a configuration for a list item
  class ListItemConfiguration
    attr_accessor :name, :archived_at, :user_id
    attr_reader :id, :created_at, :updated_at

    def initialize(name:, archived_at:, user_id:, id: nil, create_configuration: true)
      @name = name
      @archived_at = archived_at
      @user_id = user_id
      @id = id || (create if create_configuration)
    end

    def self.find_by_name(user_id, template_name)
      record = DB[:list_item_configurations].where(user_id: user_id, name: template_name).first
      raise "Template '#{template_name}' not found for user #{user_id}" unless record

      new(id: record[:id], name: record[:name], archived_at: record[:archived_at],
          user_id: record[:user_id], create_configuration: false)
    end

    private

    def create
      DB[:list_item_configurations].insert(name:, archived_at:, user_id:,
                                           created_at: Time.now, updated_at: Time.now)
    end
  end
end
