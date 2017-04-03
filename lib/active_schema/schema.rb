module ActiveSchema
  class Schema

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
      end
    end

    def add_filter(name, operator, values)
      raise 'filter is not defined!' unless available_filters.key?(name)
      filters[name] = { o: operator, v: values }
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

    def available_filters
      @available_filters ||= available_attributes.select{|att| att.filter? }.collect{|att| [att.filter_name, att] }.to_h
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
        scope = available_filter[name].add_statement(scope, attrs[:o], attrs[:v])
      end
      scope
    end


    #serialization
    def from_params(params)
      if params[:filters].is_a?(Hash)
        params[:filters].each{|name, short_filter| add_short_filter(name, short_filter) }
      end
    end

  end
end
