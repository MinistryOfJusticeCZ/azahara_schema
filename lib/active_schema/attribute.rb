module ActiveSchema
  class Attribute
    attr_accessor :name, :format, :model

    def initialize(model, name, type)
      @name, @model = name, model
      @format = ActiveSchema::FieldFormat.find(type)
    end

    def type
      format.format_name
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

    def add_statement(scope, operator, values)
      case operator
      when '='
        scope.where(filter_name => values)
      end
    end

  end
end
