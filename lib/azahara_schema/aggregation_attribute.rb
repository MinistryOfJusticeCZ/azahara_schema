# Author::    Ondřej Ezr  (mailto:oezr@msp.justice.cz)
# Copyright:: Copyright (c) 2017 Ministry of Justice
# License::   Distributes under license Open Source Licence pro Veřejnou Správu a Neziskový Sektor v.1

module AzaharaSchema
  class AggregationAttribute < Attribute

    attr_reader :attribute

    def initialize(model, attribute)
      @attribute = attribute
      super(model, 'sum:'+attribute.name, attribute.type)
    end

    def searchable?
      false
    end

    def arel_field
      attribute.arel_field.sum
    end

    def value(parent)
      val = attribute.attribute.add_join( parent.send(attribute.association.name) ).sum(attribute.arel_field)
      val = BigDecimal.new(val.to_s) unless val.is_a?(BigDecimal)
      val
    end

  end
end
