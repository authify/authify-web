class Organization < Munson::Resource
  self.type = :organizations

  has_many :users
  has_many :groups
  has_many :admins

  key_type :integer
  attribute :name, :string
  attribute :public_email, :string
  attribute :gravatar_email, :string
  attribute :billing_email, :string
  attribute :description, :string
  attribute :url, :string
  attribute :location, :string
  attribute :created_at, :time
end
