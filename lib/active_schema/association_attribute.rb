module ActiveSchema
  class AssociationAttribute < Attribute

    attr_reader :attribute, :schema, :association

    def initialize(association)
      @schema = ActiveSchema::Schema.new(association.klass, association: association)
      @attribute = @schema.main_attribute
      super(association.klass, association.name.to_s, attribute.type)
      @association = association
    end

    def path
      @association.name.to_s+'.to_s'
    end

    def column?
      association.macro == :belongs_to
    end

    def value(parent)
      parent.public_send(association.name).to_s
    end

  end
end
