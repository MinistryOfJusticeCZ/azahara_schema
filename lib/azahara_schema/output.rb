module AzaharaSchema
  class Output

    attr_reader :schema

    def self.key
      self.name.split('::').last.underscore
    end

    def initialize(schema)
      @schema = schema
    end

    def model
      @schema.model
    end

    def model_name
      model.model_name
    end

    def model_i18n_key
      model_name.i18n_key
    end

  end
end
