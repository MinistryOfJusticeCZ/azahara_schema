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

    # dummy implementations for rewrite
    def uncollapsable_filters
      available_filters.select{|name, filter| always_visible_filters.include?(name) }
    end

    def collapsable_filters
      available_filters.select{|name, filter| !always_visible_filters.include?(name) }
    end

  end
end
