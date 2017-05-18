require 'active_schema/field_format'
require 'active_schema/attribute'
require 'active_schema/association_attribute'
require 'active_schema/outputs'
require 'active_schema/output'
require 'active_schema/schema'
require 'active_schema/model_schema'

module ActiveSchema
  class Engine < ::Rails::Engine
    isolate_namespace ActiveSchema

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
    end

    config.to_prepare do
      ::ApplicationController.helper(ActiveSchema::ApplicationHelper)
    end
  end
end
