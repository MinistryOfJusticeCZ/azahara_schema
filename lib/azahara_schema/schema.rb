require 'active_support' #Hash.slice

module AzaharaSchema
  class Schema

    def self.schema_class_for(klass)
      klasses = [klass]
      while klass != klass.base_class
        klass = klass.superclass
        klasses << klass
      end
      klasses.each do |kls|
        schema_klass = "#{kls.name}Schema".safe_constantize
        return schema_klass if schema_klass
      end
      AzaharaSchema::Schema
    end

    def self.schema_for(klass, *attributes)
      model = klass
      klasses = [klass]
      while klass != klass.base_class
        klass = klass.superclass
        klasses << klass
      end
      klasses.each do |kls|
        schema_klass = "#{kls.name}Schema".safe_constantize
        if schema_klass
          return kls.try(:abstract_class?) ? schema_klass.new(model, *attributes) : schema_klass.new(*attributes)
        end
      end
      AzaharaSchema::Schema.new(model, *attributes)
    end

    def self.attribute_type(model, name, col=nil)
      col ||= model.columns_hash[name.to_s]
      if model.defined_enums[col.name]
        'list'
      else
        col && col.type
      end
    end

    def self.attribute(model, name, attr_type=nil)
      attr_type ||= attribute_type(model, name)
      Attribute.new(model, name, attr_type)
    end

    def self.attribute_for_column(model, col, attr_type=nil)
      attribute(model, col.name, attr_type || attribute_type(model, col.name, col) )
    end

    def self.enabled_filters(*filter_names)
      @enabled_filters = filter_names if filter_names.any?
      @enabled_filters ||= []
    end

    def self.operators_for_filters
      @operators_for_filters ||= {}
    end

    def self.filter_operators(filter, operators)
      operators_for_filters[filter] = operators
    end

    attr_accessor :model, :enabled_outputs, :association, :parent_schema
    attr_accessor :search_query, :default_scope
    attr_accessor :offset, :limit

    def initialize(model, **attributes)
      @model = model
      @association = attributes[:association]
      @parent_schema = attributes[:parent_schema]
      @column_names = attributes[:columns]
      @enabled_outputs = attributes[:outputs] || default_outputs
      @nested_relations_depth = attributes[:relations_depth]
    end

    def searchable_attributes
      @searchable_attributes ||= available_attributes.select{|a| a.searchable? }
    end

    def column_names=(values)
      @column_names = values
      @columns = nil
    end

    def column_names
      @column_names ||= default_columns
    end

    def columns
      @columns ||= available_attributes_hash.slice(*column_names).values
    end

    def filters
      @filters ||= {}
    end

    def sort
      @sort ||= ActiveSupport::OrderedHash.new.merge!(default_sort)
    end

    # DEFAULTS

    def default_outputs
      [AzaharaSchema::Outputs.registered_outputs.keys.first].compact
    end

    def default_columns
      [main_attribute_name]
    end

    def default_sort
      {}
    end

    # just a dummy implementation
    def main_attribute_name
      available_attributes.detect{|att| att.name != 'id' }.name
    end

    def nested_relations_depth
      @nested_relations_depth || 4
    end

    def include_associated_attributes?
      nested_relations_depth > 0
    end

    # ACCESSORS

    def add_short_filter(name, str)
      attrs = str.split('|')
      if attrs.size == 2
        operator, values = attrs
      elsif attrs.size == 1
        operator, values = '=', attrs.first
      end
      add_filter(name, operator, values.split('\\'))
    end

    def add_filter(name, operator, values)
      raise 'filter ('+name+') is not defined!' unless available_filters.key?(name)
      filters[name] = { o: operator, v: values }
    end

    def add_sort(name, order=:asc)
      sort[name] = order
    end

    def operator_for(fname)
      filters[fname] && filters[fname][:o]
    end

    def value_for(fname)
      filters[fname] && filters[fname][:v]
    end

    def operators_for(filter_name)
      operators = available_filters[filter_name] && available_filters[filter_name].available_operators
      operators &= self.class.operators_for_filters[filter_name] if operators && self.class.operators_for_filters[filter_name]
      operators
    end

    def attribute(name)
      available_attributes.detect{|att| att.name == name}
    end

    def available_attributes
      unless @available_attributes
        initialize_available_attributes
        @available_attributes.each{|at| at.table_alias = Array(association_path[1..-1]).collect(&:to_s).join('_').presence }
      end
      @available_attributes
    end

    def available_attributes_hash
      available_attributes.inject({}){|obj, aa| obj[aa.name] = aa; obj }
    end

    def available_columns
      @available_columns ||= available_attributes.select{|att| att.column? }
    end

    def enabled_filters

    end

    def disabled_filters
      []
    end

    def enabled_filter_names
      names = self.class.enabled_filters if self.class.enabled_filters.any?
      names ||= available_attributes_hash.keys
      names &= enabled_filters if enabled_filters
      names -= disabled_filters
    end

    def available_filters
      @available_filters ||= available_attributes_hash
    end

    def user_available_filters
      available_filters.slice(*enabled_filter_names)
    end

    def association_path
      @association_path ||= parent_schema ? ( parent_schema.association_path + [association.name] ) : [model.model_name.element.to_sym]
    end

    def available_associations
      return [] unless include_associated_attributes?
      @available_associations ||= model.reflect_on_all_associations.select do |association|
        !association.options[:polymorphic] &&
          association.klass != model &&
          !association_path.include?( association.name.to_s.singularize.to_sym ) &&
          !association_path.include?( association.name.to_s.pluralize.to_sym )
      end.collect do |association|
        AzaharaSchema::Schema.schema_for(association.klass, parent_schema: self, association: association, relations_depth: nested_relations_depth.try(:-, 1))
      end
    end

    def attribute_for_column(col)
      self.class.attribute_for_column(model, col)
    end

    def initialize_available_attributes
      @available_attributes ||= []
      model.columns.each do |col|
        @available_attributes << attribute_for_column(col)
      end
      available_associations.each do |asoc_schema|
        asoc_schema.available_attributes.each do |asoc_attribute|
          next if asoc_attribute.is_a?(AggregationAttribute)
          added_attribute = AssociationAttribute.new(model, asoc_schema, asoc_attribute)
          @available_attributes << added_attribute
          @available_attributes << AggregationAttribute.new(model, added_attribute) if asoc_attribute.aggregable?
        end
      end
    end

    def outputs
      Outputs.new(self)
    end

    def tokenize_search_query(query=search_query)
      query.split if query
    end

    def base_scope
      model.all
    end

    def entity_scope(scope=base_scope)
      scope = scope.visible if scope.respond_to?(:visible)
      scope = scope.send(self.default_scope) if self.default_scope
      scope
    end

    def filtered_scope
      scope = entity_scope
      filters.each do |name, attrs|
        scope = available_filters[name].add_statement(scope, attrs[:o], attrs[:v])
      end
      if (tokens = tokenize_search_query)
        searchable_attributes.each{|a| scope = a.add_join(scope) }
        arl = searchable_attributes[0].arel_statement('~', tokens) if searchable_attributes.any?
        Array(searchable_attributes[1..-1]).each{|att| arl = arl.or( att.arel_statement('~', tokens) ) }
        scope = scope.where(arl)
      end
      scope
    end

    def entity_count
      filtered_scope.count
    end

    def entities
      scope = filtered_scope
      columns.each do |col|
        scope = col.add_preload(scope)
      end
      sort.keys.reverse.each do |name|
        att = attribute(name)
        scope = att.add_sort(scope, sort[name]) if att
      end
      scope = scope.offset(offset) if offset
      scope = scope.limit(limit) if limit
      scope
    end

    def build_json_options!(options={})
      columns.each{|col| col.build_json_options!(options) }
      options
    end

    def entity_as_json(entity, options=nil)
      attr_hash = entity.as_json(options)
      # TODO serializable_add_includes(options) do |association, records, opts|
      columns.each do |col|
        col_sub_hash = attr_hash
        sub_col = col
        while sub_col.is_a?(AzaharaSchema::AssociationAttribute)
          col_sub_hash = (col_sub_hash[sub_col.association.name.to_s] ||= {})
          sub_col = sub_col.attribute
        end
        if col.type == 'love'
          col_sub_hash[sub_col.name] = sub_col.available_values.detect{|l, v| v == col_sub_hash[sub_col.name] }.try(:[], 0)
        else
          col_sub_hash[sub_col.name] = col.value(entity)
        end
      end
      attr_hash
    end

    def as_json(options={})
      build_json_options!(options)
      entities.collect{|entity| entity_as_json(entity, options) }
    end


    #serialization
    def from_params(params)
      if params[:f]
        filter_params = params[:f].permit(available_filters.keys + [available_filters.keys.inject({}){|o,name| o[name] = []; o }]).to_h
        filter_params.each do |name, filter_value|
          next if filter_value.blank?
          if filter_value.is_a?(Array)
            add_filter(name, '=', filter_value)
          else
            add_short_filter(name, filter_value)
          end
        end
      end
      if params[:c].is_a?(Array)
        self.column_names = params[:c].to_a
      end
      if params[:sort]
        @sort = nil
        params[:sort].each do |k, sort|
          add_sort(sort[:path], sort['desc'] == 'true' ? :desc : :asc )
        end
      end
      self.default_scope = params[:default_scope] if params[:default_scope]
      self.search_query = params[:q] unless params[:q].blank?
      self.offset = params[:offset] if params[:offset]
      self.limit = params[:limit] if params[:limit]
    end

    def to_param
      params = {}
      params[:f] = {}
      filters.each do |fname, attrs|
        params[:f][fname] = "#{attrs[:o]}|#{Array(attrs[:v]).collect{|v| v.to_s}.join('\\')}"
      end
      params[:default_scope] = default_scope if default_scope
      params[:c] = column_names
      params[:q] = search_query if params[:q]
      params[:offset] = offset
      params[:limit] = limit
      params
    end

    def uncollapsable_filters
      {}
    end

    def collapsable_filters
      available_filters
    end

  end
end
