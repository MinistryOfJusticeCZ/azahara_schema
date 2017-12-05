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

if Object.const_defined?('Rails')
  require "azahara_schema/engine"
end

module AzaharaSchema
  # Your code goes here...
end
