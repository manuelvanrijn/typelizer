class SerializableUser::Author < JSONAPI::Serializable::Resource
  include Typelizer::DSL

  typelize_from ::User
  typelizer_config.null_strategy = :nullable_and_optional

  type "users"

  typelize username: [:string, nullable: true, comment: "Author login handle"]
  attributes :id, :username

  has_many :posts, serializer: SerializablePost, if: ->(u) { u.posts.any? }

  attribute :avatar do
    "https://example.com/avatar.png" if @object.active?
  end

  typelize :string, nullable: true
  attribute :typed_avatar do
    "https://example.com/avatar.png" if @object.active?
  end
end
