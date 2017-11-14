require 'openssl'

module Hmac

  def self.get_nonce()
    return Time.now.to_i * (1**6)
  end

  def self.sign_request(api_secret, url, nonce, body=nil)
    if body.nil?
      message = "#{nonce}#{url}"
    else
      body = body.to_json
      message = "#{nonce}#{url}#{body}"
    end

    return OpenSSL::HMAC.hexdigest('sha256', api_secret, message)
  end
end