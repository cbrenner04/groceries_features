# frozen_string_literal: true

require "envyable"

require_relative "../spec/support/helpers/data_clean_up_helper"

Envyable.load("config/env.yml", ENV["ENV"] || "development")
results_helper = Helpers::ResultsHelper.new
results_helper.sign_in(ENV["RESULTS_USER"], ENV["RESULTS_PASSWORD"])
