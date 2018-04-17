module AzaharaSchema
  class Output

    attr_reader :schema

    def self.key
      self.name.split('::').last.sub(/Output$/, '').underscore
    end

    def key
      self.class.key
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

    # rendering
    def to_partial_path
      'azahara_schema/outputs/'+key
    end

    def formatter(template)
      template.attribute_formatter_for(schema)
    end

  end
end
