class User < McCracken::Resource
  self.type = :users

  has_many :groups
  has_many :organizations
  has_many :identities
  has_many :apikeys

  key_type :integer
  attribute :full_name, :string
  attribute :email, :string
  attribute :password, :string

  def self.register(email, name, password, omniauth_stuff = nil)
    # TODO Make this handle errors
    deets = {
      'email' => email,
      'name' => name
    }
    deets['password'] = password if password
    if omniauth_stuff
      deets['via'] = {}
      deets['via']['provider'] = omniauth_stuff[:provider]
      deets['via']['uid'] = omniauth_stuff[:uid]
    end
    raise "Unable to Register: Missing auth details" unless password || omniauth_stuff
    response = RestClient.post(
                 "#{AUTHIFY_API_URL}/registration/signup",
                 deets.to_json,
                 {
                   content_type: :json,
                   accept: :json,
                   x_authify_access: AUTHIFY_ACCESS_KEY,
                   x_authify_secret: AUTHIFY_SECRET_KEY
                 }
               )
    JSON.parse(response.body)
  end

  def self.email_verification(email, password, token)
    # TODO Make this handle errors
    deets = {
      'email' => email,
      'password' => password,
      'token' => token
    }

    response = RestClient.post(
                 "#{AUTHIFY_API_URL}/registration/verify",
                 deets.to_json,
                 {
                   content_type: :json,
                   accept: :json,
                   x_authify_access: AUTHIFY_ACCESS_KEY,
                   x_authify_secret: AUTHIFY_SECRET_KEY
                 }
               )
    JSON.parse(response.body)
  end

  def self.token_from_identity(provider, uid)
    # TODO Make this handle errors
    deets = {
      'provider' => provider,
      'uid' => uid
    }
    response = RestClient.post(
                 "#{AUTHIFY_API_URL}/jwt/token",
                 deets.to_json,
                 {
                   content_type: :json,
                   accept: :json,
                   x_authify_access: AUTHIFY_ACCESS_KEY,
                   x_authify_secret: AUTHIFY_SECRET_KEY
                 }
               )
    JSON.parse(response.body)['jwt']
  end
end
