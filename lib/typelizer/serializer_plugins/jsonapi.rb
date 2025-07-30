require_relative "base"

module Typelizer
  module SerializerPlugins
    class Jsonapi < Base
      def methods_to_typelize
        [
          :has_many, :has_one, :belongs_to, :relationship,
          :attribute, :attributes,
          :link, :meta, :type, :id
        ]
      end

      def typelize_method_transform(method:, name:, binding:, type:, attrs:)
        # Handle relationship methods that are aliases
        if [:has_many, :has_one, :belongs_to].include?(method)
          return {name => [type, attrs.merge(multi: method == :has_many)]}
        end

        # Handle generic relationship method
        if method == :relationship
          # Check if it's a has_many relationship by examining the data block
          multi = relationship_is_multi?(binding)
          return {name => [type, attrs.merge(multi: multi)]}
        end

        super
      end

      def properties
        return [] unless serializer.respond_to?(:attribute_blocks)

        properties = []

        # Add attributes
        serializer.attribute_blocks&.each do |name, block|
          properties << build_attribute_property(name, block)
        end

        # Add relationships
        serializer.relationship_blocks&.each do |name, block|
          properties << build_relationship_property(name, block)
        end

        # Add id property if defined (always present in JSON:API)
        properties << build_id_property

        # Add type property (always present in JSON:API)
        properties << build_type_property

        properties.compact
      end

      def root_key
        # JSON:API resources are typically wrapped in a 'data' key
        "data"
      end

      def meta_fields
        return nil unless serializer.respond_to?(:meta_val) || serializer.meta_block

        [
          Property.new(
            name: "meta",
            type: :object,
            optional: true,
            nullable: false,
            multi: false,
            column_name: "meta"
          )
        ]
      end

      private

      def build_attribute_property(name, block)
        Property.new(
          name: name.to_s,
          type: nil, # Will be inferred or set via typelize DSL
          optional: false,
          nullable: false,
          multi: false,
          column_name: name.to_s
        )
      end

      def build_relationship_property(name, block)
        # Check relationship options for serializer class and other options
        options = serializer.relationship_options[name.to_sym] || {}
        serializer_class = options[:serializer]

        # Create interface for the relationship if we have a serializer class
        type = serializer_class ? Interface.new(serializer: serializer_class) : nil

        Property.new(
          name: name.to_s,
          type: type,
          optional: true, # JSON:API relationships can be optional
          nullable: true,  # JSON:API relationships can be null
          multi: false,    # Will be overridden by typelize_method_transform if needed
          column_name: name.to_s
        )
      end

      def build_id_property
        Property.new(
          name: "id",
          type: :string, # JSON:API IDs are typically strings
          optional: false,
          nullable: false,
          multi: false,
          column_name: "id"
        )
      end

      def build_type_property
        Property.new(
          name: "type",
          type: :string, # JSON:API types are strings
          optional: false,
          nullable: false,
          multi: false,
          column_name: "type"
        )
      end

      def relationship_is_multi?(binding)
        # Try to determine if this is a has_many relationship
        # This is a heuristic based on common patterns
        false # Default to single relationship, will be overridden by method name
      end
    end
  end
end
