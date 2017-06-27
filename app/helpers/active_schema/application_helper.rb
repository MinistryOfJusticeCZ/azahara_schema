module ActiveSchema
  module ApplicationHelper

    def operators_for_select(schema, filter_name)
      schema.operators_for(filter_name).collect{|o| [o, o]}
    end

    def filter_field(schema, filter)
      case filter.format.format_name
      when 'list'
        select :f, filter.filter_name, options_for_select( filter.available_values, schema.value_for(filter.filter_name) ), {include_blank: true}, class: 'form-control value-field'
      else
        text_field :f, filter.filter_name, value: schema.value_for(filter.filter_name), class: 'form-control value-field'
      end
    end

  end
end
