module AzaharaSchema
  class AttributeName

    attr_reader :attribute

    def initialize(attribute)
      @attribute = attribute
    end

    # should take model, where the attribute is defined - but we have only model from associated attribute
    def human
      I18n.t(i18n_scoped_key, default: i18n_fallback_keys)
    end

    def model_i18n_key
      attribute.model.model_name.i18n_key
    end

    def i18n_key
      attribute.name
    end

    def i18n_scoped_key
      ('activerecord.attributes.' + model_i18n_key.to_s + '.' + i18n_key.to_s).to_sym
    end

    def i18n_fallback_keys
      if attribute.respond_to?(:attribute)
        parent_attr_name = attribute.attribute.attribute_name
        keys = [ parent_attr_name.i18n_scoped_key.to_sym ]
        keys.concat( parent_attr_name.i18n_fallback_keys )
        keys
      else
        [ i18n_scoped_key.to_sym ]
      end
    end
  end
end
