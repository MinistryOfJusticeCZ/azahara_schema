module AzaharaSchema
  class Engine < ::Rails::Engine
    isolate_namespace AzaharaSchema

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
    end

    initializer 'azahara_schema.controller_additions' do
      if Object.const_defined?('CanCan::ControllerResource')
        require 'azahara_schema/cancan/controller_resource_patch'
        ::CanCan::ControllerResource.send(:prepend, AzaharaSchema::CanCan::ControllerResourcePatch)

        require 'azahara_schema/controller_additions'
        ActiveSupport.on_load(:action_controller) do
          include ::AzaharaSchema::ControllerAdditions
        end
      end

      ActiveSupport.on_load(:action_controller_base) do
        helper AzaharaSchema::ApplicationHelper
      end
    end

  end
end
