module AzaharaSchema
  class AttributeName

    attr_reader :attribute

    def initialize(attribute)
      @attribute = attribute
    end

    def human(**options)
      I18n.t(i18n_scoped_key, options.merge(default: i18n_fallback_keys))
    end

    def human_list_value(value, **options)
      return '' unless value.present?
      I18n.t(i18n_scoped_list_key(value.to_s), options.merge(default: i18n_list_fallback_keys(value)+[value.to_s]))
    end

    def model_i18n_key
      attribute.model.model_name.i18n_key
    end

    def i18n_key
      attribute.name
    end

    def i18n_scope
      'activerecord.attributes.' + model_i18n_key.to_s
    end

    def i18n_scoped_key
      (i18n_scope + '.' + i18n_key.to_s).to_sym
    end

    def i18n_scoped_list_prefix
      i18n_scope + '.' + i18n_key.to_s.pluralize
    end

    def i18n_scoped_list_key(value, prefix=self.i18n_scoped_list_prefix)
      (prefix + '.' + value.to_s).to_sym
    end

    def i18n_fallback_keys
      if attribute.respond_to?(:attribute)
        parent_attr_name = attribute.attribute.attribute_name
        keys = [ parent_attr_name.i18n_scoped_key.to_sym ]
        keys.concat( parent_attr_name.i18n_fallback_keys )
        keys
      else
        []
      end
    end

    def i18n_list_fallback_prefixes
      if attribute.respond_to?(:attribute)
        parent_attr_name = attribute.attribute.attribute_name
        prefixes = [ parent_attr_name.i18n_scoped_list_prefix ]
        prefixes.concat( parent_attr_name.i18n_list_fallback_prefixes )
        prefixes
      else
        []
      end
    end

    def i18n_list_fallback_keys(value)
      i18n_list_fallback_prefixes.collect{|pref| i18n_scoped_list_key(value, pref) }
    end
  end
end
