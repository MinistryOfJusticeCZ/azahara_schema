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

    # Goes to the last level, for attribute base schema
    def base_schema
      attribute.try(:schema) || schema
    end

    def available_values
      attribute.available_values
    end

    def arel_field
      attribute.arel_field
    end

    def primary_key_name
      association.name.to_s+'-'+attribute.primary_key_name
    end

    def path
      association.name.to_s+'.'+attribute.path
    end

    def column?
      association.macro == :belongs_to && attribute.column?
    end

    def searchable?
      false
    end

    def value(parent)
      if association.macro == :has_many
        parent.public_send(association.name).collect{|record| attribute.value( record )}.flatten
      else
        entity = parent.public_send(association.name)
        attribute.value( entity ) if entity
      end
    end

    def association_hash
      { association.name => attribute.association_hash }
    end

    def arel_join(parent=nil, join_type=::Arel::Nodes::OuterJoin, a_tbl=self.arel_table)
      parent ||= self.arel_table(nil)
      joined = parent
      case association.macro
      when :has_many, :has_one
        joined = parent.join(attribute.arel_table, join_type).on( attribute.arel_table[association.foreign_key].eq( a_tbl[model.primary_key] ) )
      when :belongs_to
        joined = parent.join(attribute.arel_table, join_type).on( attribute.arel_table[attribute.model.primary_key].eq( a_tbl[association.foreign_key] ) )
      else
        raise 'Unknown macro ' + association.macro.to_s
      end
      attribute.arel_join( joined, join_type )
    end

    def arel_statement(operator, values)
      attribute.arel_statement(operator, values)
    end

    def add_join(scope)
      # scope.left_outer_joins(association_hash)
      scope.joins(arel_join.join_sources)
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
