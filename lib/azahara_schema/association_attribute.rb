# Author::    Ondřej Ezr  (mailto:oezr@msp.justice.cz)
# Copyright:: Copyright (c) 2017 Ministry of Justice
# License::   Distributes under license Open Source Licence pro Veřejnou Správu a Neziskový Sektor v.1

module AzaharaSchema

  # The class is attribute for associated record, it is used for working with related records.
  # ---
  # TODO: better way of joining the association - mandatory as +joins+ others as left outer, but not includes.
  # ---
  #
  # The class holds schema for related entity.
  class AssociationAttribute < Attribute

    attr_reader :attribute, :schema

    delegate :association, to: :schema

    def initialize(association_schema, attribute)
      @schema = association_schema
      @attribute = attribute
      super(association.klass, association.name.to_s+'-'+attribute.name, attribute.type)
    end

    def available_values
      attribute.available_values
    end

    def arel_field
      attribute.arel_field
    end

    def path
      association.name.to_s+'.'+attribute.path
    end

    def column?
      association.macro == :belongs_to
    end

    def value(parent)
      parent.public_send(association.name).to_s
    end

    def add_join(scope)
      if attribute.is_a?(AzaharaSchema::AssociationAttribute)
        scope.includes(association.name => attribute.association.name).references(association.name => attribute.association.name)
      else
        scope.includes(association.name).references(association.name)
      end
    end

    def add_preload(scope)
      if attribute.is_a?(AzaharaSchema::AssociationAttribute)
        scope.preload(association.name => attribute.association.name)
      else
        scope.preload(association.name)
      end
    end

    def add_statement(scope, operator, values)
      super(add_join(scope), operator, values)
    end

    def add_sort(scope, order)
      super(add_join(scope), order)
    end

    def build_json_options!(options)
      options[:include] ||= {}
      options[:include][association.name.to_sym] ||= {}
      attribute.build_json_options!(options[:include][association.name.to_sym])
      options
    end

  end
end
