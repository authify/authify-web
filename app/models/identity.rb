class Identity < Munson::Resource
  self.type = :identities
  has_one :user

  key_type :integer
  attribute :provider, :string
  attribute :uid, :string
end
