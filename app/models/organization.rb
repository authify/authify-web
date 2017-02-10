class Organization < Munson::Resource
  self.type = :organizations

  has_many :users
  has_many :groups

  key_type :integer
  attribute :name, :string
end
