require 'azahara_schema/field_format'

module AzaharaSchema
  class Attribute
    attr_accessor :name, :format, :model, :table_alias

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

    def arel_table(t_alias=self.table_alias)
      t_alias ? model.arel_table.alias(t_alias) : model.arel_table
    end

    def arel_field(t_alias=self.table_alias)
      arel_table(t_alias)[filter_name]
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

    # Name of the primary key attribute (same as column obviously)
    def primary_key_name
      model.primary_key
    end

    def column?
      true
    end

    def filter?
      true
    end

    def aggregable?
      format.aggregable?
    end

    def searchable?
      format.searchable?
    end

    def value(record)
      record.public_send(name)
    end

    # values has to be array!
    def arel_statement(operator, values)
      values = values.collect{|v| format.sanitize_value(v) }
      case operator
      when '='
        condition = arel_field.in(values.compact) if values.compact.any?
        if values.include?(nil)
          c_nil = arel_field.eq(nil)
          condition = condition ? condition.or(c_nil) : c_nil
        end
        condition
      when '~'
        vals = values.collect{|v| v.split }.flatten
        arl = arel_field.matches("%#{vals[0]}%")
        vals[1..-1].each{|v| arl = arl.or( arel_field.matches("%#{v}%") ) }
        arl
      when '>='
        arel_field.gteq(values.map(&:to_f).min)
      when '<='
        arel_field.lteq(values.map(&:to_f).max)
      else
        throw 'Unknown operator ' + operator.to_s
      end
    end

    def add_join(scope)
      scope
    end

    def add_preload(scope)
      scope
    end

    def add_statement(scope, operator, values)
      values = [values] unless values.is_a?(Array)
      scope.where(arel_statement(operator, values))
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

    def arel_join(parent=nil, join_type=::Arel::Nodes::OuterJoin, a_tbl=self.arel_table(self.table_alias))
      parent
    end

  end
end
