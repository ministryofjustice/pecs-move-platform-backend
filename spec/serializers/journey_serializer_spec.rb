# frozen_string_literal: true

require 'rails_helper'

RSpec.describe JourneySerializer do
  subject(:serializer) { described_class.new(journey, adapter_options) }

  let(:journey) { create :journey, client_timestamp: '2020-05-04T08:00:00Z' }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }
  let(:adapter_options) { {} }

  it 'contains a type property' do
    expect(result[:data][:type]).to eql 'journeys'
  end

  it 'contains an `id` property' do
    expect(result[:data][:id]).to eql journey.id
  end

  it 'contains a `billable` attribute' do
    expect(result[:data][:attributes][:billable]).to be false
  end

  it 'contains a `state` attribute' do
    expect(result[:data][:attributes][:state]).to eql 'proposed'
  end

  it 'contains a `timestamp` attribute' do
    expect(result[:data][:attributes][:timestamp]).to eql '2020-05-04T09:00:00+01:00'
  end

  it 'contains vehicle attributes' do
    expect(result[:data][:attributes][:vehicle]).to eql(id: '12345678ABC', registration: 'AB12 CDE')
  end

  it 'contains a `from_location` relationship' do
    expect(result[:data][:relationships][:from_location]).to eql(data: { id: journey.from_location.id, type: 'locations' })
  end

  it 'contains a `to_location` relationship' do
    expect(result[:data][:relationships][:to_location]).to eql(data: { id: journey.to_location.id, type: 'locations' })
  end

  describe 'included relationships' do
    let(:adapter_options) do
      {
        include: %w[from_location to_location],
      }
    end
    let(:expected_json) do
      [
        {
          id: journey.from_location_id,
          type: 'locations',
          attributes: { location_type: journey.from_location.location_type, title: journey.from_location.title },
        },
        {
          id: journey.to_location_id,
          type: 'locations',
          attributes: { location_type: journey.to_location.location_type, title: journey.to_location.title },
        },
      ]
    end

    it 'contains an included from and to location' do
      expect(result[:included]).to(include_json(expected_json))
    end
  end

  describe 'generic_events' do
    let(:adapter_options) { { include: %i[events] } }

    context 'with generic events' do
      let(:now) { Time.zone.now }
      let!(:first_event) { create(:event_journey_uncancel, eventable: journey, occurred_at: now + 2.seconds) }
      let!(:second_event) { create(:event_journey_cancel, eventable: journey, occurred_at: now + 1.second) }
      let!(:third_event) { create(:event_journey_start, eventable: journey, occurred_at: now) }

      let(:expected_event_relationships) do
        [
          { id: third_event.id, type: 'events' },
          { id: second_event.id, type: 'events' },
          { id: first_event.id, type: 'events' },
        ]
      end

      it 'contains event relationships' do
        expect(result[:data][:relationships][:events]).to eq(data: expected_event_relationships)
      end

      it 'contains included events' do
        expect(result[:included].map { |event| event[:id] }).to match_array([third_event.id, second_event.id, first_event.id])
      end
    end

    context 'without generic events' do
      it 'contains an empty allocation' do
        expect(result_data[:relationships][:events]).to eq(data: [])
      end

      it 'does not contain an included event' do
        expect(result[:included]).to be_blank
      end
    end
  end
end
