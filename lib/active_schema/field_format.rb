module ActiveSchema
  module FieldFormat
    def self.add(name, klass)
      all[name.to_s] = klass.instance
    end

    def self.delete(name)
      all.delete(name.to_s)
    end

    def self.all
      @formats ||= Hash.new(Base.instance)
    end

    def self.available_formats
      all.keys
    end

    def self.find(name)
      all[name.to_s]
    end

    # Return an array of custom field formats which can be used in select_tag
    def self.as_select(class_name=nil)
      formats = all.values.select do |format|
        format.class.customized_class_names.nil? || format.class.customized_class_names.include?(class_name)
      end
      formats.map {|format| [::I18n.t(format.label), format.name] }.sort_by(&:first)
    end

    class Base
      include Singleton

      class_attribute :format_name
      self.format_name = nil

      def self.add(name)
        self.format_name = name
        ActiveSchema::FieldFormat.add(name, self)
      end
      private_class_method :add

      def available_operators
        ['=']
      end
    end

    class Number < Base
      def available_operators
        super.concat(['>=','<=', '><'])
      end
    end

    class Integer < Number
      add 'integer'
    end

    class StringFormat < Base
      add 'string'

      def available_operators
        super.concat(['~'])
      end
    end

    class ListFormat < StringFormat
      add 'list'

      def available_operators
        ['=']
      end
    end

    class DateTimeFormat < Base
      add 'datetime'
    end

  end
end
