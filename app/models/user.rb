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
      'name': name,
      'password' => password
    }
    if omniauth_stuff
      deets['via'] = {}
      deets['via']['provider'] = omniauth_stuff[:provider]
      deets['via']['provider'] = omniauth_stuff[:uid]
    end
    response = RestClient.post "#{AUTHIFY_API_URL}/registration/signup",
              deets.to_json,
              { content_type: :json, accept: :json }
    JSON.parse(response.body)['jwt']
  end
end
