# frozen_string_literal: true

require "envyable"
require "sequel"

require_relative "../support/helpers/data_clean_up_helper"

Envyable.load("config/env.yml", ENV["ENV"] || "development")
DB = Sequel.connect(ENV.fetch("DATABASE_URL", nil))
Helpers::DataCleanUpHelper.new(DB).remove_test_data
