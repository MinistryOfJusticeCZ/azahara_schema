require 'spec_helper'

require 'azahara_schema'

RSpec.describe AzaharaSchema::Attribute do

  let(:model) { class_spy('User') }
  let(:scope) { instance_double('ActiveRecord::Relation', model: model) }
  let(:arel_field) { double('arel_field') }
  let(:attribute) { a = AzaharaSchema::Attribute.new(model, 'name', 'string'); allow(a).to receive(:arel_field).and_return(arel_field); a }

  describe '#add_statement' do
    before(:each) { allow(scope).to receive(:where).and_return(scope) }

    context 'with operator tilda' do
      it 'calls arel_field#matches with one value' do
        value = 'Vondracek'
        expect(arel_field).to receive(:matches).with("%#{value}%").twice
        attribute.add_statement(scope, '~', value)
        attribute.add_statement(scope, '~', [value])
      end
      it 'calls arel_field#matches three times connected by OR with three values' do
        values = ['Vondracek', 'Novy', 'Krepela']

        first_match_res = instance_double('Arel::Nodes::Matches')
        second_match_res = instance_double('Arel::Nodes::Matches')
        third_match_res = instance_double('Arel::Nodes::Matches')
        first_or_res = instance_double('Arel::Nodes::Grouping')
        # third_lvl_res = instance_double('Arel::Nodes::Grouping')

        expect(arel_field).to receive(:matches).with("%#{values[0]}%").and_return( first_match_res )
        expect(arel_field).to receive(:matches).with("%#{values[1]}%").and_return( second_match_res )
        expect(arel_field).to receive(:matches).with("%#{values[2]}%").and_return( third_match_res )
        expect(first_match_res).to receive(:or).with(second_match_res).and_return( first_or_res )
        expect(first_or_res).to receive(:or).with(third_match_res)

        attribute.add_statement(scope, '~', values)
      end
    end
  end

end
