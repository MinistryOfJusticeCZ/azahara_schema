module AzaharaSchema
  module ControllerAdditions

    def azahara_schema_index(**options)
      @resource_schema = self.class.cancan_resource_class.new(self).send(:collection_instance)
      @resource_schema.from_params(params)
      respond_to do |format|
        format.html
        format.json {
          json_result = {}
          if params['_type'] == 'query'
            json_result[:results] = @resource_schema.entities.collect do |o|
                {id: o.id, text: o.to_s, residence: o.person.residence.to_s}
              end
          elsif params['_type'] == 'count'
            json_result = {count: @resource_schema.entity_count}
          else
            json_result = {entities: @resource_schema, count: @resource_schema.entity_count}
          end
          render json: json_result
        }
        format.csv {
          require 'csv'
          headers['Content-Disposition'] = "attachment; filename=\"#{@resource_schema.model.model_name.human(count: :other)}.csv\""
          headers['Content-Type'] ||= 'text/csv'
          render @resource_schema.csv_template, layout: false
        }
      end
    end

  end
end
