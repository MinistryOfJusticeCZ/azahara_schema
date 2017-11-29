# redefine cancan collection load to schema load
module AzaharaSchema
  module CanCan
    module ControllerResourcePatch

      def load_collection
        schema = ::AzaharaSchema::Schema.schema_for(resource_class)
        if @options[:trough]
          schema.add_filter(parent_name.to_s+'_id', '=', parent_resource.id)
        end
        schema.visibility_scope!(current_ability, authorization_action)
        schema
      end

    end
  end
end
