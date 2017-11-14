require 'bundler/setup'
require 'faraday'
require 'faraday_middleware'
require 'coins_ph_ruby/version'
require 'coins_ph_ruby/hmac'

module CoinsPhRuby
  class CoinsPhService

    def initialize(api_key, api_secret)
      @API_KEY = api_key
      @API_SECRET = api_secret
      @BASE_URL = 'https://coins.ph/api/v3'
      @conn = Faraday.new @BASE_URL do |connector|
        connector.use FaradayMiddleware::FollowRedirects
        connector.adapter Faraday.default_adapter
      end
    end

    def get_crypto_accounts(currency=nil)
      url = BASE_URL + "/crypto-accounts/"
      nonce = Hmac.get_nonce.to_s
      signature = Hmac.sign_request(@API_SECRET, url, nonce)

      response = @conn.get do |req|
        req.url 'crypto-accounts'
        req.headers['Content-Type'] = 'application/json'
        req.headers['Accept'] = 'application/json'
        req.headers['ACCESS_SIGNATURE'] = signature
        req.headers['ACCESS_KEY'] = @API_KEY
        req.headers['ACCESS_NONCE'] = nonce
      end

      puts response.body
      return response
    end

    def get_transfers(id=nil)
      nonce = Hmac.get_nonce.to_s
      url = BASE_URL + "/transfers"

      response = @conn.get do |req|
        req.url 'transfers'
        req.headers['Content-Type'] = 'application/json'
        req.headers['Accept'] = 'application/json'
        req.headers['ACCESS_SIGNATURE'] = Hmac.sign_request(@API_SECRET, url, nonce)
        req.headers['ACCESS_KEY'] = @API_KEY
        req.headers['ACCESS_NONCE'] = nonce
      end

      puts response.inspect
      return response
    end

    def transfer (amount, account, target_address, message)
      body = "{
        'amount': #{amount},
        'account': #{account},
        'target_address': #{target_address}
        'message': #{message}
      }"

      nonce = Hmac.get_nonce.to_s
      url = BASE_URL + "/transfers"

      response = @conn.post do |req|
        req.url 'transfers'
        req.headers['Content-Type'] = 'application/json'
        req.headers['Accept'] = 'application/json'

        req.headers['ACCESS_SIGNATURE'] = Hmac.sign_request(@API_SECRET, url, nonce, body)
        req.headers['ACCESS_KEY'] = @API_KEY
        req.headers['ACCESS_NONCE'] = nonce

        req.body = body
      end

      puts response.body
      return response
    end
  end
end
