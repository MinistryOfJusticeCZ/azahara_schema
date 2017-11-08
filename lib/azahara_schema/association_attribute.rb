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

    def initialize(model, association_schema, attribute)
      @schema = association_schema
      @attribute = attribute
      super(model, association.name.to_s+'-'+attribute.name, attribute.type)
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

    def searchable?
      false
    end

    def value(parent)
      if association.macro == :has_many
        parent.public_send(association.name).collect{|record| attribute.value( record )}.flatten
      else
        attribute.value( parent.public_send(association.name) )
      end
    end

    def association_hash
      { association.name => attribute.association_hash }
    end

    def add_join(scope)
      scope.includes(association_hash).references(association_hash)
    end

    def add_preload(scope)
      scope.preload(association_hash)
    end

    # TODO: heuristic for when add left outer join and when add inner join
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
