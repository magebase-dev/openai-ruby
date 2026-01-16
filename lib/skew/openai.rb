# frozen_string_literal: true

require "openai"
require "httparty"
require "json"
require "securerandom"

module Skew
  module OpenAI
    # SKEW-wrapped OpenAI client - Drop-in replacement
    #
    # Usage:
    #   # Before
    #   require "openai"
    #   client = OpenAI::Client.new(access_token: api_key)
    #
    #   # After
    #   require "skew/openai"
    #   client = Skew::OpenAI::Client.new(access_token: api_key)
    #
    #   # Works exactly the same!
    class Client < ::OpenAI::Client
      SKEW_API_KEY = ENV.fetch("SKEW_API_KEY", "")
      SKEW_TELEMETRY_ENDPOINT = ENV.fetch("SKEW_TELEMETRY_ENDPOINT", "https://api.skew.ai/v1/telemetry")
      SKEW_PROXY_ENABLED = ENV.fetch("SKEW_PROXY_ENABLED", "false") == "true"
      SKEW_BASE_URL = ENV.fetch("SKEW_BASE_URL", "https://api.skew.ai/v1/openai")

      def initialize(options = {})
        super(options)
        @telemetry_enabled = !SKEW_API_KEY.empty?
        @telemetry_buffer = []
        @telemetry_mutex = Mutex.new

        start_telemetry if @telemetry_enabled
      end

      def chat(parameters:)
        start_time = Time.now
        request_id = "req_#{Time.now.to_i}_#{SecureRandom.hex(4)}"

        begin
          result = super(parameters: parameters)
          end_time = Time.now

          if @telemetry_enabled
            record_telemetry(
              request_id: request_id,
              timestamp_start: start_time.utc.iso8601,
              timestamp_end: end_time.utc.iso8601,
              model: parameters[:model] || "unknown",
              endpoint: "chat.completions",
              latency_ms: ((end_time - start_time) * 1000).to_i,
              token_usage: {
                prompt_tokens: result.dig("usage", "prompt_tokens") || 0,
                completion_tokens: result.dig("usage", "completion_tokens") || 0,
                total_tokens: result.dig("usage", "total_tokens") || 0
              },
              cost_estimate_usd: estimate_cost(
                parameters[:model],
                result.dig("usage", "prompt_tokens") || 0,
                result.dig("usage", "completion_tokens") || 0
              ),
              status: "success"
            )
          end

          result
        rescue => error
          end_time = Time.now

          if @telemetry_enabled
            record_telemetry(
              request_id: request_id,
              timestamp_start: start_time.utc.iso8601,
              timestamp_end: end_time.utc.iso8601,
              model: parameters[:model] || "unknown",
              endpoint: "chat.completions",
              latency_ms: ((end_time - start_time) * 1000).to_i,
              token_usage: { prompt_tokens: 0, completion_tokens: 0, total_tokens: 0 },
              cost_estimate_usd: 0,
              status: "error",
              error_class: error.class.name,
              error_message: error.message
            )
          end

          raise
        end
      end

      private

      def record_telemetry(event)
        @telemetry_mutex.synchronize do
          @telemetry_buffer << event

          flush_telemetry if @telemetry_buffer.size >= 10
        end
      end

      def flush_telemetry
        return if @telemetry_buffer.empty?

        batch = @telemetry_buffer.dup
        @telemetry_buffer.clear

        Thread.new do
          begin
            HTTParty.post(
              SKEW_TELEMETRY_ENDPOINT,
              headers: {
                "Content-Type" => "application/json",
                "Authorization" => "Bearer #{SKEW_API_KEY}"
              },
              body: { events: batch }.to_json,
              timeout: 5
            )
          rescue
            # Silent drop - telemetry must never break user's app
          end
        end
      end

      def start_telemetry
        Thread.new do
          loop do
            sleep 5
            @telemetry_mutex.synchronize { flush_telemetry }
          end
        end
      end

      def estimate_cost(model, prompt_tokens, completion_tokens)
        pricing = {
          "gpt-4o" => { input: 2.5, output: 10.0 },
          "gpt-4o-mini" => { input: 0.15, output: 0.6 },
          "gpt-4-turbo" => { input: 10.0, output: 30.0 },
          "gpt-4" => { input: 30.0, output: 60.0 },
          "gpt-3.5-turbo" => { input: 0.5, output: 1.5 }
        }

        model_pricing = pricing[model] || { input: 0.01, output: 0.01 }
        (prompt_tokens / 1_000_000.0) * model_pricing[:input] +
          (completion_tokens / 1_000_000.0) * model_pricing[:output]
      end
    end
  end
end
