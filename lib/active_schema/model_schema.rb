module ActiveSchema
  class ModelSchema < Schema
    def initialize(**attributes)
      super(model, attributes)
    end

    def model
      @model ||= self.class.name.sub(/Schema/, '').constantize
    end


  end
end
