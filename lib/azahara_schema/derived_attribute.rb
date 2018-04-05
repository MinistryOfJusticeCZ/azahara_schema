# Author::    Ondřej Ezr  (mailto:oezr@msp.justice.cz)
# Copyright:: Copyright (c) 2017 Ministry of Justice
# License::   Distributes under license Open Source Licence pro Veřejnou Správu a Neziskový Sektor v.1

module AzaharaSchema

  # The class is attribute for derivateve attribute, it is used for working with combination of attributes as one attribute.
  class DerivedAttribute < Attribute

    attr_accessor :derivation_method
    attr_accessor :attribute_names

    def initialize(model, name, derivation_method, *attribute_names, **options)
      self.attribute_names = attribute_names
      self.derivation_method = derivation_method.to_sym
      @options = options
      super(model, name, type)
    end

    # ------------------| MY METHODS |----------------------

    # TODO: check if attributes support derivation method
    def attribute_names=(names)
      @attributes = nil
      @attribute_names = names
    end

    def attributes
      @attributes ||= options[:attributes] || options[:schema].available_attributes_hash.slice(*attribute_names).values
    end

    def concat_divider
      options[:divider] || ' '
    end

    def options
      @options || {}
    end

    # -------------------| OVERRIDES |---------------------

    def type
      case derivation_method
      when :concat
        'string'
      else
        raise "DerivedAttribute(#{name}) - derivation_method '#{derivation_method}' is not supported"
      end
    end

    # do not alias tables - let attributes derived from handle that
    def arel_field(t_alias=nil)
      case derivation_method
      when :concat
        arel_fields = attributes.collect{|a| a.arel_field}
        (1..arel_fields.length-1).to_a.reverse.each{|i| arel_fields.insert(i, Arel::Nodes::SqlLiteral.new("'#{concat_divider}'")) }
        Arel::Nodes::NamedFunction.new 'CONCAT', arel_fields
      else
        raise "DerivedAttribute(#{name}) - derivation_method '#{derivation_method}' is not supported"
      end
    end

    def value(record)
      attributes.collect{|a| a.value(record) }.join(concat_divider)
    end

    def arel_statement(operator, values)
      case operator
      when '~'
        arl = attributes[0].arel_statement(operator, values)
        attributes[1..-1].each{|att| arl = arl.or( att.arel_statement(operator, values) ) }
        arl
      else
        super
      end
    end

    def add_statement(scope, operator, values)
      super(add_join(scope), operator, values)
    end

    def arel_join(parent=nil, join_type=::Arel::Nodes::OuterJoin, a_tbl=self.arel_table(self.table_alias))
      parent ||= self.arel_table(nil)
      joined = parent
      attributes.each{|a| joined = a.arel_join(joined, join_type) }
      joined
    end

    def add_join(scope)
      attributes.each{|a| scope = a.add_join(scope) }
      scope
    end

    def add_preload(scope)
      attributes.each{|a| scope = a.add_preload(scope) }
      scope
    end

  end
end
