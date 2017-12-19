module AzaharaSchema
  module ApplicationHelper

    def operators_for_select(schema, filter_name)
      schema.operators_for(filter_name).collect{|o| [o, o]}
    end

    def filter_field(schema, filter)
      case filter.format.format_name
      when 'list', 'love'
        select :f, filter.filter_name, options_for_select( list_values_for_select(filter), schema.value_for(filter.filter_name) ), {include_blank: true}, class: 'form-control value-field'
      else
        text_field :f, filter.filter_name, value: schema.value_for(filter.filter_name), class: 'form-control value-field'
      end
    end

    # translates values to list_values
    # TODO: not needed to do it for every value - for example districts are not translatable
    def list_values_for_select(attribute)
      if attribute.format.format_name == 'list'
        attribute.available_values.collect do |l, val|
          [t(l, scope: [:activerecord, :attributes, attribute.model.model_name.i18n_key, attribute.name.to_s.pluralize], default: l.to_s), val]
        end
      else
        attribute.available_values
      end
    end

    def attribute_formatter_for(schema_or_model, **options)
      AttributeFormatter.formatter_for(schema_or_model).new(schema_or_model, self, options)
    end

    def unfilled_attribute_message
      content_tag(:span, t('label_unfilled'), class: 'unfilled-message')
    end

  end
end
