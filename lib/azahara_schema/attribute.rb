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
      case operator
      when '='
        scope.where( arel_field.eq(values) )
      when '~'
        scope.where( arel_field.matches("%#{values}%") )
      when '>='
        scope.where( arel_field.gteq(values) )
      when '<='
        scope.where( arel_field.lteq(values) )
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

  end
end
