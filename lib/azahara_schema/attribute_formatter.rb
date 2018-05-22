module AzaharaSchema
  class AttributeFormatter

    def self.default_formatter=(formatter_klass)
      @default_formatter = formatter_klass
    end

    def self.default_formatter
      @default_formatter || AzaharaSchema::AttributeFormatter
    end

    def self.formatter_for(schema_or_entity)
      klass = schema_or_entity.class if !schema_or_entity.is_a?(Class)
      klass = schema_or_entity.model if schema_or_entity.is_a?(::AzaharaSchema::Schema)
      klass ||= schema_or_entity
      klasses = [klass]
      while klass != klass.base_class
        klass = klass.superclass
        klasses << klass
      end
      klasses.each do |kls|
        schema_klass = "#{kls.name}Formatter".safe_constantize || "Formatters::#{kls.name}Formatter".safe_constantize
        return schema_klass if schema_klass
      end
      default_formatter
    end

    attr_reader :model, :template

    def initialize(schema_or_entity, template, **options)
      @schema = schema_or_entity if schema_or_entity.is_a?(::AzaharaSchema::Schema)
      @entity = schema_or_entity if schema_or_entity.is_a?(::ActiveRecord::Base)
      @model = @schema ? @schema.model : (@entity ? schema_or_entity.class : schema_or_entity)
      @options = options
      @template = template
    end

    def new_path(**options)
      template.new_polymorphic_path(model, options)
    end

    def show_path(entity, **options)
      template.polymorphic_path(entity, options)
    end

    def icon_class_for_attribute(attribute)
      'fa'
    end

    def human_value(attribute, value, **options)
      case attribute.type
      when 'love'
        attribute.available_values.detect{|l, v| v == value }.try(:[], 0)
      when 'list'
        attribute.attribute_name.human_list_value(value, options)
      when 'datetime'
        value ? l(value) : value
      else
        value
      end
    end

    def attribute_human_value(attribute, entity, **options)
      human_value(attribute, attribute.value(entity))
    end

    def formatted_value(attribute, entity, **options)
      real_formatter(attribute).format_value(attribute, attribute_human_value(attribute, entity), formatting_options(attribute,entity).merge(options))
    end

    def html_formatted_value(attribute, entity, **options)
      format_value_html(attribute, attribute_human_value(attribute, entity, options), formatting_options(attribute,entity).merge(options))
    end

    def attribute_html_label(attribute, **options)
      attribute.attribute_name.human(options)
    end

    def labeled_html_attribute_value(attribute, entity, **options)
      template.content_tag('div', class: 'attribute') do
        s = ''.html_safe
        s << template.content_tag('div', attribute_html_label(attribute, options), class: 'label')
        s << template.content_tag('div', html_formatted_value(attribute, entity, options), class: 'value')
        s
      end
    end


    def format_value(attribute, unformated_value, **options)
      unformated_value
    end

    def format_value_html(attribute, unformated_value, **options)
      real_formatter(attribute).format_value(attribute, unformated_value, options) || template.unfilled_attribute_message
    end

    def formatting_options(attribute, entity)
      {}
    end

    def real_formatter(attribute)
      if attribute.respond_to?(:attribute)
        self.class.formatter_for(attribute.attribute.model).new(attribute.attribute.model, template, @options).real_formatter(attribute.attribute)
      else
        self
      end
    end

    def real_formatter_and_attribute(attribute)
      if attribute.respond_to?(:attribute)
        self.class.formatter_for(attribute.attribute.model).new(attribute.attribute.model, template, @options).real_formatter_and_attribute(attribute.attribute)
      else
        [self, attribute]
      end
    end

    def with_real_formatter_and_attribute(attribute, &block)
      yield real_formatter_and_attribute(attribute)
    end

    private
      delegate :l, :t, to: :template

  end
end
