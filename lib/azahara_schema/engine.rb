require 'azahara_schema/field_format'
require 'azahara_schema/attribute'
require 'azahara_schema/association_attribute'
require 'azahara_schema/aggregation_attribute'
require 'azahara_schema/derived_attribute'
require 'azahara_schema/attribute_name'
require 'azahara_schema/outputs'
require 'azahara_schema/output'
require 'azahara_schema/schema'
require 'azahara_schema/model_schema'
require 'azahara_schema/attribute_formatter'

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

    end

    config.to_prepare do
      ::ApplicationController.helper(AzaharaSchema::ApplicationHelper)
    end
  end
end
