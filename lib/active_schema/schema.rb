module ActiveSchema
  class Schema

    def self.enabled_filters(*filter_names)
      @enabled_filters = filter_names if filter_names.any?
      @enabled_filters
    end

    attr_accessor :model, :column_names

    def initialize(model, **attributes)
      @model = model
      @column_names = attributes[:columns]
      @association = attributes[:association]
    end

    def columns
      @columns ||= available_attributes.select{|attribute| attribute.column? && column_names.include?(attribute.name) }
    end

    def filters
      @filters ||= {}
    end

    def add_short_filter(name, str)
      attrs = str.split('|')
      if attrs.size == 2
        add_filter(name, attrs.first, attrs.second)
      elsif attrs.size == 1
        add_filter(name, '=', attrs.first)
      end
    end

    def add_filter(name, operator, values)
      raise 'filter is not defined!' unless available_filters.key?(name)
      filters[name] = { o: operator, v: values }
    end

    def operator_for(fname)
      filters[fname] && filters[fname][:o]
    end

    def value_for(fname)
      filters[fname] && filters[fname][:v]
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

    def available_columns
      available_attributes.select{|att| att.column? }
    end

    def enabled_filters
      if self.class.enabled_filters.any?
        self.class.enabled_filters.collect{|f_name| available_attributes.detect{|attr| attr.name == f_name } }.compact
      else
        available_attributes
      end
    end

    def available_filters
      @available_filters ||= enabled_filters.select{|att| att.filter? }.collect{|att| [att.filter_name, att] }.to_h
    end

    def initialize_available_attributes
      @available_attributes ||= []
      model.columns.each do |col|
        @available_attributes << Attribute.new(model, col.name, col.type)
      end
      model.reflect_on_all_associations.each do |association|
        @available_attributes << AssociationAttribute.new(association)
      end unless @association #only first level of association - would need to solve circular dependency - too lazy to do it
    end

    # just a dummy implementation
    def main_attribute
      available_attributes.detect{|att| att.name != 'id' }
    end

    def outputs
      Outputs.new(self)
    end

    def entities
      scope = model.respond_to?(:visible) ? model.visible : model.all
      filters.each do |name, attrs|
        scope = available_filters[name].add_statement(scope, attrs[:o], attrs[:v])
      end
      scope
    end


    #serialization
    def from_params(params)
      if params[:f]
        filter_params = params[:f].permit(available_filters.keys).to_h
        filter_params.each{|name, short_filter| add_short_filter(name, short_filter) }
      end
    end

    def to_param
      params = {}
      params[:f] = {}
      filters.each do |fname, attrs|
        params[:f][fname] = "#{attrs[:o]}|#{attrs[:v]}"
      end
      params
    end

  end
end
