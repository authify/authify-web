class User < Munson::Resource
  self.type = :users

  has_many :groups
  has_many :organizations
  has_many :identities
  has_many :api_keys

  key_type :integer
  attribute :full_name, :string
  attribute :email, :string

  def self.register(email, name, password, omniauth_stuff = nil)
    # TODO Make this handle errors
    deets = {
      'email' => email,
      'name' => name,
      'delegate' => {
        'access' => AUTHIFY_ACCESS_KEY,
        'secret' => AUTHIFY_SECRET_KEY
      }
    }
    deets['password'] = password if password
    if omniauth_stuff
      deets['via'] = {}
      deets['via']['provider'] = omniauth_stuff[:provider]
      deets['via']['uid'] = omniauth_stuff[:uid]
    end
    raise "Unable to Register: Missing auth details" unless password || omniauth_stuff
    response = RestClient.post "#{AUTHIFY_API_URL}/registration/signup",
              deets.to_json,
              { content_type: :json, accept: :json }
    JSON.parse(response.body)['jwt']
  end

  def self.token_from_identity(provider, uid)
    # TODO Make this handle errors
    deets = {
      'provider' => provider,
      'uid' => uid,
      'delegate' => {
        'access' => AUTHIFY_ACCESS_KEY,
        'secret' => AUTHIFY_SECRET_KEY
      }
    }
    response = RestClient.post "#{AUTHIFY_API_URL}/jwt/token",
              deets.to_json,
              { content_type: :json, accept: :json }
    JSON.parse(response.body)['jwt']
  end
end
