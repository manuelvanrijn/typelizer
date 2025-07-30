class SerializablePost < JSONAPI::Serializable::Resource
  include Typelizer::DSL

  typelize_from ::Post
  typelizer_config.null_strategy = :nullable_and_optional

  type "posts"

  attributes :id, :title, :category, :body, :published_at

  has_one :user, serializer: SerializableUser

  typelize :string
  attribute :name, deprecated: "Use 'title' instead."
  def name
    @object.title
  end
end
