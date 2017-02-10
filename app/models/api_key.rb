class APIKey < Munson::Resource
  self.type = :api_keys
  has_one :user

  key_type :integer
  attribute :access_key, :string
end
