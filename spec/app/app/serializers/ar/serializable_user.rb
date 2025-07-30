module Ar
  class SerializableUser < JSONAPI::Serializable::Resource
    include Typelizer::DSL

    typelize_from ::User
    typelizer_config.null_strategy = :nullable_and_optional
    typelizer_config.associations_strategy = :active_record

    type "users"

    attributes :id, :username

    has_one :invitor, serializer: SerializableUser

    has_many :posts, serializer: SerializablePost
    has_one :latest_post, serializer: SerializablePost # Duplicated association
  end
end
