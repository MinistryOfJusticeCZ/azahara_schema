module AzaharaSchema
  module ApplicationHelper

    def operators_for_select(schema, filter_name)
      schema.operators_for(filter_name).collect{|o| [o, o]}
    end

    def azahara_operators_tag(schema, filter, name)
      field_name = "f[#{name}]"
      if schema.operators_for(name).count > 1
        select_tag field_name, options_for_select(operators_for_select(schema, name), schema.operator_for(name)), class: 'form-control operator-field'
      else
        hidden_field_tag field_name, schema.operators_for(name).first, class: 'operator-field'
      end
    end

    def filter_field(schema, filter)
      case filter.format.format_name
      when 'list', 'love'
        select :f, filter.filter_name, options_for_select( list_values_for_select(filter), schema.value_for(filter.filter_name) ), {include_blank: true}, class: 'form-control value-field'
      else
        text_field :f, filter.filter_name, value: schema.value_for(filter.filter_name), class: 'form-control value-field'
      end
    end

    def azahara_filter_row(schema, filter, name=nil)
      name ||= filter.filter_name
      content_tag(:div, class: 'form-group row filter', data: {name: name}) do
        s = ''.html_safe
        s << content_tag(:div, label_tag("f[#{name}]", filter.attribute_name.human), class: 'col-md-2 control-label')

        operators_tag = azahara_operators_tag(schema, filter, name)
        if schema.operators_for(name).count > 1
          s << content_tag(:div, operators_tag, class: 'col-md-2')
          s << content_tag(:div, filter_field(schema, filter), class: 'col-md-8')
        else
          s << content_tag(:div, operators_tag + filter_field(schema, filter), class: 'col-md-10')
        end
        s
      end
    end

    # translates values to list_values
    # TODO: not needed to do it for every value - for example districts are not translatable
    def list_values_for_select(attribute)
      if attribute.format.format_name == 'list'
        attribute.available_values.collect do |l, val|
          [attribute.attribute_name.human_list_value(l), val]
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
