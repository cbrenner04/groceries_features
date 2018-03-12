# frozen_string_literal: true

require 'rest-client'
require 'json'

module Helpers
  # helpers for post results
  class ResultsHelper
    def initialize(environment, user, password, url, spec)
      @environment = environment || 'development'
      @user = user
      @password = password
      @url = url
      @spec = spec
    end

    def create_results
      post_results
      delete_token
    end

    private

    def auth_token
      return @auth_token if @auth_token
      response = RestClient.post(
        "#{@url}/sign-in.json",
        user_login: { email: @user, password: @password }
      )
      @auth_token = JSON.parse(response.body)['auth_token']
    end

    def feature_id
      return @feature_id if @feature_id
      response = RestClient::Request.execute(
        method: :post,
        url: "#{@url}/features.json",
        payload: { feature: feature_payload },
        headers: { 'Authorization' => "Token token=#{auth_token}" }
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
        headers: { 'Authorization' => "Token token=#{auth_token}" }
      )
    end

    def result_payload
      {
        feature_id: feature_id,
        duration: Time.now - @spec.execution_result.started_at,
        exception: @spec.exception&.to_s,
        passed: @spec.exception.nil?,
        environment: @environment
      }
    end

    def delete_token
      RestClient.delete(
        "#{@url}/sign-out.json",
        'Authorization' => "Token token=#{auth_token}"
      )
    end
  end
end
