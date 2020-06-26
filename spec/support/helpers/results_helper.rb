# frozen_string_literal: true

require 'rest-client'
require 'json'

module Helpers
  # helpers for post results
  class ResultsHelper
    def initialize(environment, user, password, url, spec, test_run)
      @environment = environment || 'development'
      @user = user
      @password = password
      @url = url
      @spec = spec
      @test_run = test_run
    end

    def create_results
      # TODO: this should not fail if it can't post results
      set_auth_token unless @auth_token
      return unless @auth_token

      set_feature_id unless @feature_id
      post_results
      delete_token
    end

    private

    def set_auth_token
      response = RestClient.post(
        "#{@url}/sign-in.json",
        user_login: { email: @user, password: @password }
      )
      @auth_token = JSON.parse(response.body)['auth_token']
    rescue Errno::ECONNREFUSED
      # if can't connect to feature results, auth token doesn't matter
      @auth_token = nil
    end

    def set_feature_id
      response = RestClient::Request.execute(
        method: :post,
        url: "#{@url}/features.json",
        payload: { feature: feature_payload },
        headers: { 'Authorization' => "Token token=#{@auth_token}" }
      )
      @feature_id = JSON.parse(response.body)['feature_id']
    end

    def feature_payload
      { rspec_id: @spec.id, description: @spec.full_description }
    end

    def post_results
      RestClient::Request.execute(
        method: :post,
        url: "#{@url}/results.json",
        payload: { result: result_payload },
        headers: { 'Authorization' => "Token token=#{@auth_token}" }
      )
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

    def delete_token
      RestClient.delete(
        "#{@url}/sign-out.json",
        'Authorization' => "Token token=#{@auth_token}"
      )
    end
  end
end
