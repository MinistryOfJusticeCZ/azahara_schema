require 'azahara_schema/field_format'
require 'azahara_schema/attribute'
require 'azahara_schema/association_attribute'
require 'azahara_schema/attribute_name'
require 'azahara_schema/outputs'
require 'azahara_schema/output'
require 'azahara_schema/schema'
require 'azahara_schema/model_schema'

module AzaharaSchema
  class Engine < ::Rails::Engine
    isolate_namespace AzaharaSchema

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
    end

    config.to_prepare do
      ::ApplicationController.helper(AzaharaSchema::ApplicationHelper)
    end
  end
end
