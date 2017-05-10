require 'auth_middleware'
McCracken.configure(url: AUTHIFY_API_URL.to_s)
Linguistics.use(:en)

module McCracken
  class Resource
    def self.via_mccracken(user = nil)
      opts = { url: AUTHIFY_API_URL.to_s, response_key_format: :dasherize }
      email = user ? user['username'] : nil
      connection = McCracken::Connection.new(opts) do |c|
        c.use Middleware::AuthifyTrustedDelegate, email: email
      end
      mccracken.connection = connection
      yield self
    end
  end
end
