class JsonWebToken
  # Using application's secret_key_base as the key for jwt encoding
  HMAC_SECRET = Rails.application.credentials.secret_key_base

  def self.encode(payload, exp = 24.hours.from_now)
    # Use 24 hours from creation time for token expiration
    payload[:exp] = exp.to_i
    # Encode payload with application secret
    JWT.encode(payload, HMAC_SECRET)
  end

  def self.decode(token)
    # Get payload from the first index of decoded array
    body = JWT.decode(token, HMAC_SECRET)[0]
    HashWithIndifferentAccess.new body
    # rescue from any error encountered during decoding
  rescue JWT::DecodeError => begin
    # Raise Custom error to be handled by handler
    raise ExceptionHandler::InvalidToken, e.message
  end

  module ExceptionHandler
    extend ActiveSupport::Concern

    class AuthenticationError < StandardError; end
    class MissingToken < StandardError; end
    class InvalidToken < StandardError; end

    included do
      rescue_from ActiveRecord::RecordInvalid, with: :four_twenty_two
      rescue_from ExceptionHandler::AuthenticationError, with: :unauthorized_request
      rescue_from ExceptionHandler::MissingToken, with: :four_twenty_two
      rescue_from ExceptionHandler::InvalidToken, with: :four_twenty_two

      rescue_from ActiveRecord::RecordNotFound do |e|
        json_response({message: e.message }, :not_found)
      end
    end

    private

    # JSON response with Status code 422 - unprocessable entity
    def four_twenty_two(e)
      json_response({ message: e.message }, :unprocessable_entity)
    end

    #JSON response with Status code 401 - Unauthorized
    def unauthorized_request(e)
      json_response({ message: e.message }, :unauthorized)
    end
  end
end