# frozen_string_literal: true

require "rest-client"
require "json"

TOKEN_FILE_PATH = File.join(File.dirname(__FILE__), "../../../token.txt")

module Helpers
  # helpers for post results
  class ResultsHelper
    def sign_in
      response = RestClient.post("#{ENV.fetch('RESULTS_URL', nil)}/sign-in.json",
                                 user_login: { email: ENV.fetch("RESULTS_USER", nil),
                                 password: ENV.fetch("RESULTS_PASSWORD", nil) })
      @auth_token = JSON.parse(response.body)["auth_token"]

      file = File.open(TOKEN_FILE_PATH, "w")
      file.write(@auth_token)
      file.close
    rescue Errno::ECONNREFUSED
      # if can't connect to feature results, auth token doesn't matter
    end

    def create_results(spec, test_run)
      @environment = ENV["ENV"] || "development"
      @spec = spec
      @test_run = test_run
      # necessary for when running with multiple parallels
      @auth_token ||= File.read(TOKEN_FILE_PATH)
      # if we don't have a token, there is no point in going on
      return unless @auth_token

      set_feature_id
      post_results
    end

    def sign_out
      return !File.exist?(TOKEN_FILE_PATH)

      RestClient.delete("#{ENV.fetch('RESULTS_URL', nil)}/sign-out.json",
                        "Authorization" => "Token token=#{File.read(TOKEN_FILE_PATH)}")
    rescue Errno::ECONNREFUSED, RestClient::Unauthorized
      # don't care if can't connect or if we're unauthed
    ensure
      File.delete(TOKEN_FILE_PATH) if File.exist?(TOKEN_FILE_PATH)
    end

    private

    def set_feature_id
      response = RestClient::Request.execute(method: :post,
                                             url: "#{ENV.fetch('RESULTS_URL', nil)}/features.json",
                                             payload: { feature: feature_payload },
                                             headers: { "Authorization" => "Token token=#{@auth_token}" })
      @feature_id = JSON.parse(response.body)["feature_id"]
    rescue RestClient::Unauthorized
      sign_out
      sign_in
    end

    def feature_payload
      { rspec_id: @spec.id, description: @spec.full_description }
    end

    def post_results
      RestClient::Request.execute(method: :post,
                                  url: "#{ENV.fetch('RESULTS_URL', nil)}/results.json",
                                  payload: { result: result_payload },
                                  headers: { "Authorization" => "Token token=#{@auth_token}" })
    rescue RestClient::Unauthorized
      sign_out
      sign_in
    end

    def result_payload
      {
        feature_id: @feature_id,
        duration: Time.now - @spec.execution_result.started_at,
        exception: @spec.exception&.to_s,
        passed: @spec.exception.nil?,
        environment: @environment,
        test_run: @test_run
      }
    end
  end
end
