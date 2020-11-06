# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenericEventSerializer do
  subject(:serializer) { described_class.new(event, adapter_options) }

  before do
    allow(SerializerVersionChooser).to receive(:call).and_call_original
  end

  let(:event) { create :event_move_cancel }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }

  let(:expected_json) do
    {
      data: {
        id: event.id,
        type: 'events',
        attributes: {
          occurred_at: event.occurred_at.iso8601,
          recorded_at: event.recorded_at.iso8601,
          notes: 'Flibble',
          event_type: 'MoveCancel',
          details: {
            cancellation_reason: 'made_in_error',
            cancellation_reason_comment: 'It was a mistake',
          },
        },
        relationships: {
          eventable: { data: { type: 'moves', id: event.eventable.id } },
          supplier: { data: { type: 'suppliers', id: event.supplier.id } },
        },
      },
    }
  end

  context 'with no options' do
    let(:adapter_options) { {} }

    it { expect(result).to include_json(expected_json) }
    it { expect(result[:included]).to be_nil }

    it 'uses the SerializerVersionChooser' do
      result
      # Once for the relationship
      expect(SerializerVersionChooser).to have_received(:call).with(Move).once
    end
  end

  context 'with include eventable' do
    let(:adapter_options) { { include: [:eventable] } }

    it { expect(result).to include_json(expected_json) }
    it { expect(result[:included].map { |include| include[:type] }).to eq(%w[moves]) }

    it 'uses the SerializerVersionChooser' do
      result
      # Once for the relationship, once for the include
      expect(SerializerVersionChooser).to have_received(:call).with(Move).twice
    end
  end
end
