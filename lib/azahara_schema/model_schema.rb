module AzaharaSchema
  class ModelSchema < Schema

    def initialize(**attrs)
      super(model, attrs)
    end

    def always_visible_filters
      []
    end

    def model
      @model ||= self.class.name.sub(/Schema/, '').constantize
    end

    def visibility_scope!(ability, authorization_action=:index)
      @entity_scope = model.accessible_by(ability, authorization_action)
    end

    def entity_scope
      @entity_scope || super
    end

    # dummy implementations for rewrite
    def uncollapsable_filters
      available_filters.select{|name, filter| always_visible_filters.include?(name) }
    end

    def collapsable_filters
      available_filters.select{|name, filter| !always_visible_filters.include?(name) }
    end

    # rendering
    def to_partial_path
      'azahara_schema/schema'
    end

  end
end
