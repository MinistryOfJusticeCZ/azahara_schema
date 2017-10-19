require 'spec_helper'

require 'azahara_schema/schema'

RSpec.describe AzaharaSchema::Schema do

  describe '#available_filters' do
    let(:model) { class_spy('User') }
    let(:attributes) do
      [
        instance_double('AzaharaSchema::Attribute', name: 'id'),
        instance_double('AzaharaSchema::Attribute', name: 'name'),
        instance_double('AzaharaSchema::Attribute', name: 'created_at')
      ]
    end
    subject { s = AzaharaSchema::Schema.new(model); allow(s).to receive(:available_attributes).and_return(attributes); s }

    context 'with enabled_filters overwritten' do
      before(:each) { allow(AzaharaSchema::Schema).to receive(:enabled_filters).and_return(['name', 'created_at']) }

      it 'returns attributes enabled on class' do
        expect(subject.available_filters.keys).to eq(['name', 'created_at'])
      end

      it 'returns just attributes enabled on both - class and instance' do
        allow(subject).to receive(:enabled_filters).and_return(['name'])
        expect(subject.available_filters.keys).to eq(['name'])
      end

      it 'returns attributes enabled on class but without disabled on instance' do
        allow(subject).to receive(:disabled_filters).and_return(['created_at'])
        expect(subject.available_filters.keys).to eq(['name'])
      end
    end
  end
end
