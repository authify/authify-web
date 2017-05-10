class Group < McCracken::Resource
  self.type = :groups

  has_many :users
  has_one :organization

  key_type :integer
  attribute :name, :string
end
