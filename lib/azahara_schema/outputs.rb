module AzaharaSchema
  class Outputs

    include Enumerable

    def self.registered_outputs
      @registered_outputs ||= {}
    end

    def self.register(klass)
      key = klass.key
      registered_outputs[key] = klass
      define_method(key) do
        output(key)
      end
      true
    end

    def self.output_class(output)
      registered_outputs[output]
    end

    def initialize(schema)
      @schema = schema
    end

    def output(output)
      self.class.output_class(output).new(@schema)
    end

    def each(&block)
      @schema.enabled_outputs.each do |o|
        yield output(o)
      end
    end

  end
end
