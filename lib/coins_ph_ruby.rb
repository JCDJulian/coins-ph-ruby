require 'faraday'
require 'faraday_middleware'
require 'coins_ph_ruby/version'
require 'coins_ph_ruby/hmac'

module CoinsPhRuby
  class RequestBody < Faraday::Middleware
    def call(env)
      request_body = env.body

      puts request_body

      @app.call(env).on_complete do |response|
        response[:request_body] = request_body
      end
    end
  end

  class CoinsPhService

    def initialize(api_key, api_secret)
      @api_key = api_key
      @api_secret = api_secret
      @base_url = 'https://coins.ph/api/v3'
      @conn = Faraday.new @base_url do |connector|
        connector.use FaradayMiddleware::FollowRedirects
        connector.use RequestBody
        connector.adapter Faraday.default_adapter
      end
    end

    def get_crypto_accounts(currency=nil)
      url = @base_url + "/crypto-accounts/"
      nonce = Hmac.get_nonce.to_s
      signature = Hmac.sign_request(@api_secret, url, nonce)

      response = @conn.get do |req|
        req.url 'crypto-accounts'
        req.headers['Content-Type'] = 'application/json'
        req.headers['Accept'] = 'application/json'
        req.headers['ACCESS_SIGNATURE'] = signature
        req.headers['ACCESS_KEY'] = @api_key
        req.headers['ACCESS_NONCE'] = nonce
      end

      puts response.body
      return response
    end

    def get_transfers(id=nil)
      nonce = Hmac.get_nonce.to_s
      url = @base_url + "/transfers/"

      response = @conn.get do |req|
        req.url 'transfers'
        req.headers['Content-Type'] = 'application/json'
        req.headers['Accept'] = 'application/json'
        req.headers['ACCESS_SIGNATURE'] = Hmac.sign_request(@api_secret, url, nonce)
        req.headers['ACCESS_KEY'] = @api_key
        req.headers['ACCESS_NONCE'] = nonce
      end

      puts response.body
      return response
    end

    def transfer (amount, account, target_address, message)
      body = "{
        \"amount\": \"#{amount}\",
        \"account\": \"#{account}\",
        \"target_address\": \"#{target_address}\",
        \"message\": \"#{message}\"
      }".gsub(/\s+/, "")

      nonce = Hmac.get_nonce.to_s
      url = @base_url + "/transfers/"

      response = @conn.post do |req|
        req.url 'transfers'
        req.headers['Content-Type'] = 'application/json'
        req.headers['Accept'] = 'application/json'

        req.headers['ACCESS_SIGNATURE'] = Hmac.sign_request(@api_secret, url,
                                                            nonce)
        req.headers['ACCESS_KEY'] = @api_key
        req.headers['ACCESS_NONCE'] = nonce

        req.body = body

        puts req.inspect
      end

      puts response.inspect
      return response
    end
  end
end
