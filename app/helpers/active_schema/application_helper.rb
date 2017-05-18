module ActiveSchema
  module ApplicationHelper

    def operators_for_select(schema, filter_name)
      schema.operators_for(filter_name).collect{|o| [o, o]}
    end

  end
end
