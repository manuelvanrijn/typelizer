class SerializableUser < JSONAPI::Serializable::Resource
  include Typelizer::DSL

  typelize_from ::User
  typelizer_config.null_strategy = :nullable_and_optional

  type "users"

  attributes :id, :username, :active, :name

  has_one :invitor, serializer: SerializableUser

  has_many :posts, serializer: SerializablePost

  typelize id: [:string, nullable: true]

  typelize :string
  attribute :first_name do
    @object.username.split(" ").first
  end

  class Foo < SerializableUser
    typelize_from ::User
    attributes :created_at

    typelize id: [:number, optional: true]
  end
end
