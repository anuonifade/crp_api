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
  rescue JWT::DecodeError => e
    # Raise Custom error to be handled by handler
    raise ExceptionHandler::InvalidToken, e.message
  end
end