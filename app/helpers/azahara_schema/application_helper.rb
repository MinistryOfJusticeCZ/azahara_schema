module AzaharaSchema
  module ApplicationHelper

    def operators_for_select(schema, filter_name)
      schema.operators_for(filter_name).collect{|o| [o, o]}
    end

    def filter_field(schema, filter)
      case filter.format.format_name
      when 'list'
        select :f, filter.filter_name, options_for_select( list_values_for_select(filter), schema.value_for(filter.filter_name) ), {include_blank: true}, class: 'form-control value-field'
      else
        text_field :f, filter.filter_name, value: schema.value_for(filter.filter_name), class: 'form-control value-field'
      end
    end

    def list_values_for_select(attribute)
      attribute.available_values.collect{|l, val| t(l, scope: [:activerecord, :attributes, attribute.model.model_name.i18n_key, attribute.name.to_s.pluralize], default: l.to_s.humanize) }
    end

  end
end
