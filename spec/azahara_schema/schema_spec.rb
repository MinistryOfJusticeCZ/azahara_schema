require 'spec_helper'

require 'azahara_schema/schema'

RSpec.describe AzaharaSchema::Schema do

  context 'with stubed schema' do
    let(:model) { class_spy('User') }
    let(:attributes) do
      [
        instance_double('AzaharaSchema::Attribute', name: 'id', type: 'integer'),
        instance_double('AzaharaSchema::Attribute', name: 'name', type: 'string'),
        instance_double('AzaharaSchema::Attribute', name: 'gender', type: 'love'),
        instance_double('AzaharaSchema::Attribute', name: 'created_at', type: 'datetime')
      ]
    end
    let(:schema) { s = AzaharaSchema::Schema.new(model); allow(s).to receive(:available_attributes).and_return(attributes); s }

    describe '#available_filters' do

      context 'with enabled_filters overwritten' do
        before(:each) { allow(AzaharaSchema::Schema).to receive(:enabled_filters).and_return(['name', 'created_at']) }

        it 'returns attributes enabled on class' do
          expect(schema.available_filters.keys).to eq(['name', 'created_at'])
        end

        it 'returns just attributes enabled on both - class and instance' do
          allow(schema).to receive(:enabled_filters).and_return(['name'])
          expect(schema.available_filters.keys).to eq(['name'])
        end

        it 'returns attributes enabled on class but without disabled on instance' do
          allow(schema).to receive(:disabled_filters).and_return(['created_at'])
          expect(schema.available_filters.keys).to eq(['name'])
        end
      end
    end

    describe 'filters' do
      let(:scope) { instance_double('ActiveRecord::Relation', model: model) }

      before(:each) do
        allow(model).to receive(:visible).and_return(scope)
      end

      it 'call attribute #add_statement' do
        values = ['Vondracek']
        schema.column_names = []
        expect(attributes[1]).to receive(:add_statement).with(scope, '~', values)
        schema.add_filter('name', '~', values)
        schema.entities
      end
    end

    describe 'search_query' do
      let(:scope) { instance_double('ActiveRecord::Relation', model: model) }

      before(:each) do
        allow(model).to receive(:visible).and_return(scope)
        allow(schema).to receive(:searchable_attributes).and_return(attributes[1..2])
      end

      it 'adds search statements' do
        first_or_res = instance_double('Arel::Nodes::Grouping')
        second_or_res = instance_double('Arel::Nodes::Grouping')
        grouped_res = instance_double('Arel::Nodes::Grouping')
        schema.column_names = []
        schema.search_query = 'Vondracek Nejedly'
        tokens = schema.search_query.split

        expect(attributes[1]).to receive(:add_join).with(scope).and_return(scope)
        expect(attributes[2]).to receive(:add_join).with(scope).and_return(scope)
        expect(attributes[1]).to receive(:arel_statement).with('~', tokens).and_return(first_or_res)
        expect(attributes[2]).to receive(:arel_statement).with('~', tokens).and_return(second_or_res)
        expect(first_or_res).to receive(:or).with(second_or_res).and_return(grouped_res)
        expect(scope).to receive(:where).with(grouped_res).and_return(scope)

        schema.entities
      end
    end

    describe '#add_short_filter' do
      it 'with operator and one value' do
        values = ['A']
        expect(schema).to receive(:add_filter).with('name', '~', values)
        schema.add_short_filter('name', '~|A')
      end
      it 'without operator' do
        values = ['A']
        expect(schema).to receive(:add_filter).with('name', '=', values)
        schema.add_short_filter('name', 'A')
      end
      it 'without operator with two values' do
        values = ['A', 'B']
        expect(schema).to receive(:add_filter).with('name', '=', values)
        schema.add_short_filter('name', 'A\B')
      end
      it 'with operator and two values' do
        values = ['A', 'B']
        expect(schema).to receive(:add_filter).with('name', '=', values)
        schema.add_short_filter('name', 'A\B')
      end
    end

  end
end
