require 'coins_ph_ruby/version'
require 'coins_ph_ruby/hmac'
require 'json'

module CoinsPhRuby
  class CoinsPhService
    def initialize(api_key, api_secret)
      @api_key = api_key
      @api_secret = api_secret
      @base_url = 'https://coins.ph/api/v3'
    end

    def get_crypto_accounts(_currency = nil)
      nonce = Hmac.get_nonce
      url = @base_url + '/crypto-accounts/'
      signature = Hmac.sign_request(@api_secret, url, nonce)
      RestClient.get(url, content_type: :json,
                          accept: :json,
                          ACCESS_SIGNATURE: signature,
                          ACCESS_KEY: @api_key,
                          ACCESS_NONCE: nonce)
    end

    def get_transfers(_id = nil)
      nonce = Hmac.get_nonce
      url = @base_url + '/transfers/'
      signature = Hmac.sign_request(@api_secret, url, nonce)
      RestClient.get(url, content_type: :json,
                          accept: :json,
                          ACCESS_SIGNATURE: signature,
                          ACCESS_KEY: @api_key,
                          ACCESS_NONCE: nonce)
    end

    def transfer(amount, account, target_address, message = nil)
      body = build_transfer_body(account, amount, message, target_address)
      nonce = Hmac.get_nonce
      url = @base_url + '/transfers/'
      signature = Hmac.sign_request(@api_secret, url,
                                    nonce, body)
      RestClient.post(url, body, content_type: :json,
                                 accept: :json,
                                 ACCESS_SIGNATURE: signature,
                                 ACCESS_KEY: @api_key,
                                 ACCESS_NONCE: nonce)
    end

    private

    def build_transfer_body(account, amount, message, target_address)
      body = {
        target_address: target_address,
        account: account,
        amount: amount
      }
      body[:message] = message unless message.nil?
      body.to_json.gsub(/\s+/, '')
    end
  end
end
