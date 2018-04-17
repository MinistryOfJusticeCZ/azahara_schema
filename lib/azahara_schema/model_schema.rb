module AzaharaSchema
  class ModelSchema < Schema

    def initialize(*attrs)
      attributes = attrs.last.is_a?(Hash) ? attrs.pop : {}
      super(attrs.first || model, attributes)
    end

    def export_template
      'azahara_schema/exports/common'
    end

    def csv_template
      export_template
    end

    def always_visible_filters
      []
    end

    def model
      @model ||= self.class.name.sub(/Schema/, '').constantize
    end

    def visibility_scope!(ability, authorization_action=:index)
      @entity_scope = entity_scope.accessible_by(ability, authorization_action)
    end

    def entity_scope
      @entity_scope || super
    end

    # dummy implementations for rewrite
    def uncollapsable_filters
      user_available_filters.select{|name, filter| always_visible_filters.include?(name) }
    end

    def collapsable_filters
      user_available_filters.select{|name, filter| !always_visible_filters.include?(name) }
    end

    # rendering
    def to_partial_path
      'azahara_schema/schema'
    end

  end
end
