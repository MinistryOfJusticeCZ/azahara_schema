require 'active_support' #Hash.slice

module AzaharaSchema
  class Schema

    def self.schema_for(klass, *attributes)
      klasses = [klass]
      while klass != klass.base_class
        klass = klass.superclass
        klasses << klass
      end
      klasses.each do |kls|
        schema_klass = "#{kls.name}Schema".safe_constantize
        return schema_klass.new(*attributes) if schema_klass
      end
      AzaharaSchema::Schema.new(klass, *attributes)
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

    attr_accessor :model, :association, :parent_schema

    def initialize(model, **attributes)
      @model = model
      @association = attributes[:association]
      @parent_schema = attributes[:parent_schema]
      @column_names = attributes[:columns]
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
      @sort ||= default_sort
    end

    # DEFAULTS

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

    def follow_nested_relations
      true
    end

    # ACCESSORS

    def add_short_filter(name, str)
      attrs = str.split('|')
      if attrs.size == 2
        add_filter(name, attrs.first, attrs.second)
      elsif attrs.size == 1
        add_filter(name, '=', attrs.first)
      end
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
      @available_filters ||= available_attributes_hash.slice(*enabled_filter_names)
    end

    def association_path
      @association_path ||= parent_schema ? ( [association.name].concat(parent_schema.association_path) )
    end

    def available_associations
      @available_associations ||= model.reflect_on_all_associations.select do |association|
        association.klass != model && !association_path.include?( association.name )
      end.collect do |association|
        AzaharaSchema::Schema.schema_for(association.klass, parent_schema: self, association: association)
      end
    end

    def attribute_for_column(col)
      Attribute.new(model, col.name, col.type)
    end

    def initialize_available_attributes
      @available_attributes ||= []
      model.columns.each do |col|
        @available_attributes << attribute_for_column(col)
      end
      available_associations.each do |asoc_schema|
        asoc_schema.available_attributes.each do |asoc_attribute|
          @available_attributes << AssociationAttribute.new(model, asoc_schema, asoc_attribute)
        end
      end
    end

    def outputs
      Outputs.new(self)
    end

    def entities
      scope = model.respond_to?(:visible) ? model.visible : model.all
      columns.each do |col|
        scope = col.add_preload(scope)
      end
      filters.each do |name, attrs|
        scope = available_filters[name].add_statement(scope, attrs[:o], attrs[:v])
      end
      sort.each do |name, order|
        att = attribute(name)
        scope = att.add_sort(scope, order) if att
      end
      scope
    end

    def build_json_options!(options={})
      columns.each{|col| col.build_json_options!(options) }
      options
    end

    def as_json(options={})
      entities.as_json(build_json_options!(options))
    end


    #serialization
    def from_params(params)
      if params[:f]
        filter_params = params[:f].permit(available_filters.keys).to_h
        filter_params.each{|name, short_filter| add_short_filter(name, short_filter) }
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
    end

    def to_param
      params = {}
      params[:f] = {}
      filters.each do |fname, attrs|
        params[:f][fname] = "#{attrs[:o]}|#{attrs[:v]}"
      end
      params[:c] = column_names
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
