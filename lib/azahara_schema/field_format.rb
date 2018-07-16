require 'singleton'
require 'active_support' #class_attribute
require 'active_support/core_ext' #class_attribute

module AzaharaSchema
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
        AzaharaSchema::FieldFormat.add(name, self)
      end
      private_class_method :add

      def available_operators
        ['=']
      end

      def aggregable?
        false
      end

      def searchable?
        false
      end

      def sanitize_value(value)
        value
      end
    end

    class NumberFormat < Base
      def available_operators
        super.concat(['>=','<=', '><'])
      end

      def aggregable?
        true
      end
    end

    class IntegerFormat < NumberFormat
      add 'integer'

      def sanitize_value(value)
        value.to_s.present? ? value.to_s.to_i : nil
      end
    end

    class FloatFormat < NumberFormat
      add 'float'

      def sanitize_value(value)
        value.to_s.present? ? value.to_s.to_f : nil
      end
    end

    class DecimalFormat < FloatFormat
      add 'decimal'
    end

    class BooleanFormat < Base
      add 'boolean'

      def sanitize_value(value)
        case value
        when '0', 'false', false
          false
        when nil
          nil
        else
          !!value
        end
      end
    end

    class StringFormat < Base
      add 'string'

      def available_operators
        super.concat(['~'])
      end

      def searchable?
        true
      end

      def sanitize_value(value)
        value.to_s.presence
      end
    end

    class TextFormat < StringFormat
      add 'text'
    end

    class ListFormat < StringFormat
      add 'list'

      def available_operators
        ['=']
      end

      def searchable?
        false
      end
    end

    class LoveFormat < ListFormat
      add 'love'
    end

    class DateFormat < Base
      add 'date'
    end

    class DateTimeFormat < Base
      add 'datetime'
    end

  end
end
