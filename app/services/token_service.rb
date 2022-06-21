module TokenService
  def self.encode(data)
    iss_payload = { data:, iss: ENV['RSS_API_URL'] }
    JWT.encode iss_payload, ENV['RSS_TOKEN_PASS'], 'HS256'

  end

  def self.decode(token)
    JWT.decode token, ENV['RSS_TOKEN_PASS'], true, { iss: ENV['RSS_API_URL'], verify_iss: true, algorithm: 'HS256' }
  end
end
