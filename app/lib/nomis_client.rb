# frozen_string_literal: true

class NomisClient
  class << self
    def get(path, params = {})
      token.get("#{ENV['NOMIS_API_PATH_PREFIX']}#{path}", params: params)
    end

    private

    REFRESH_TOKEN_TIMEFRAME_IN_SECONDS = 5

    def client
      @client ||= OAuth2::Client.new(
        ENV['NOMIS_CLIENT_ID'],
        ENV['NOMIS_CLIENT_SECRET'],
        site: ENV['NOMIS_SITE'],
        auth_scheme: ENV['NOMIS_AUTH_SCHEME'],
        token_url: "#{ENV['NOMIS_AUTH_PATH_PREFIX']}/oauth/token",
        raise_errors: false
      )
    end

    def token
      @token ||= client.client_credentials.get_token
      @token.refresh! if token_expired_or_to_expire?
      @token
    end

    def token_expired_or_to_expire?
      @token.expires? &&
        (@token.expires_at - REFRESH_TOKEN_TIMEFRAME_IN_SECONDS < Time.now.to_i)
    end
  end
end
