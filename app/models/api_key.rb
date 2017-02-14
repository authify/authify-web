class APIKey < Munson::Resource
  self.type = :apikeys
  has_one :user

  key_type :integer
  attribute :access_key, :string
  attribute :secret_key, :string
end
