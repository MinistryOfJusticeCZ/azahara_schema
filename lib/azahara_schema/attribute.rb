require 'azahara_schema/field_format'

module AzaharaSchema
  class Attribute
    attr_accessor :name, :format, :model

    def initialize(model, name, type)
      @name, @model = name, model
      @format = AzaharaSchema::FieldFormat.find(type)
    end

    def available_operators
      format.available_operators
    end

    def available_values
      case type
      when 'list'
        @model.try(name.to_s.pluralize)
      else
        nil
      end
    end

    def type
      format.format_name
    end

    def arel_field
      model.arel_table[filter_name]
    end

    def arel_sort_field
      arel_field
    end

    def filter_name
      name
    end

    # Path in json structure
    def path
      name
    end

    def column?
      true
    end

    def filter?
      true
    end

    def value(record)
      record.public_send(name)
    end

    def add_preload(scope)
      scope
    end

    def add_statement(scope, operator, values)
      values = [values] unless values.is_a?(Array)
      case operator
      when '='
        scope.where( arel_field.in(values) )
      when '~'
        arl = arel_field.matches("%#{values[0]}%")
        values[1..-1].each{|v| arl = arl.or( arel_field.matches("%#{v}%") ) }
        scope.where( arl )
      when '>='
        scope.where( arel_field.gteq(values.map(&:to_f).min) )
      when '<='
        scope.where( arel_field.lteq(values.map(&:to_f).max) )
      else
        throw 'Unknown operator ' + operator.to_s
      end
    end

    def add_sort(scope, order)
      scope.order( arel_sort_field.public_send(order) )
    end

    def build_json_options!(options)
      options
    end

    def attribute_name
      AzaharaSchema::AttributeName.new(self)
    end

    def association_hash
      {}
    end

  end
end
