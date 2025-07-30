module Ar
  class SerializablePost < JSONAPI::Serializable::Resource
    include Typelizer::DSL

    typelize_from ::Post
    typelizer_config.null_strategy = :nullable_and_optional
    typelizer_config.associations_strategy = :active_record

    type "posts"

    attributes :id, :title

    has_one :user, serializer: SerializableUser
  end
end
