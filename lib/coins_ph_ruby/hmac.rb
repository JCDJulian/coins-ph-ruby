require 'openssl'

module Hmac

  def self.get_nonce()
    return Time.now.to_i * (10**8)
  end

  def self.sign_request(api_secret, url, nonce, body=nil)
    puts nonce
    puts url
    if body.nil?
      message = "#{nonce}#{url}"
    else
      message = "#{nonce}#{url}#{body}"

    end

    puts message
    digest = OpenSSL::Digest.new('sha256')
    return OpenSSL::HMAC.hexdigest(digest, api_secret, message)
  end
end

{"target_address":"ethan@groundworkai.com","account":"02d950370daf41c1a1de060b3cb48a9d","amount":3}
{"target_address":"ethan@groundworkai.com","amount":3,"account":"02d950370daf41c1a1de060b3cb48a9d"}