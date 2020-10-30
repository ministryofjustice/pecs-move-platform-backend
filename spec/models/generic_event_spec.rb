require 'rails_helper'

RSpec.describe GenericEvent, type: :model do
  subject(:generic_event) { build(:event_move_cancel) }

  it { is_expected.to belong_to(:eventable) }
  it { is_expected.to belong_to(:supplier).optional }
  it { is_expected.to validate_presence_of(:eventable) }
  it { is_expected.to validate_presence_of(:type) }
  it { is_expected.to validate_presence_of(:occurred_at) }
  it { is_expected.to validate_presence_of(:recorded_at) }

  it { expect(described_class).to respond_to(:applied_order) }

  it 'updates the parent record when updated' do
    eventable = create(:move)
    event = create(:event_move_cancel, eventable: eventable)

    expect { event.update(occurred_at: event.occurred_at + 1.day) }.to change { eventable.reload.updated_at }
  end

  it 'updates the parent record when created' do
    eventable = create(:move)

    expect { create(:event_move_cancel, eventable: eventable) }.to change { eventable.reload.updated_at }
  end

  it 'defines the correct STI classes for validation' do
    expected_sti_classes = Dir['app/models/generic_event/*'].map { |file|
      file
        .sub('app/models/generic_event/', '')
        .sub('.rb', '')
        .camelcase
    } - %w[Incident]

    expect(described_class::STI_CLASSES).to match_array(expected_sti_classes)
  end

  describe '#trigger' do
    subject(:generic_event) { create(:event_move_cancel) }

    it 'does nothing to the eventable attributes by default' do
      expect { generic_event.trigger }.not_to change { generic_event.reload.eventable.attributes }
    end
  end

  describe '#for_feed' do
    subject(:generic_event) { create(:event_move_cancel, supplier: create(:supplier, key: 'serco')) }

    it 'returns the expected attributes' do
      expected_attributes = {
        'id' => generic_event.id,
        'type' => 'MoveCancel',
        'notes' => 'Flibble',
        'created_at' => be_a(Time),
        'updated_at' => be_a(Time),
        'occurred_at' => be_a(Time),
        'recorded_at' => be_a(Time),
        'eventable_id' => generic_event.eventable_id,
        'eventable_type' => 'Move',
        'details' => { 'cancellation_reason' => 'made_in_error', 'cancellation_reason_comment' => 'It was a mistake' },
        'supplier' => 'serco',
      }

      expect(generic_event.for_feed).to include_json(expected_attributes)
    end
  end

  describe '.from_event' do
    let(:event) { create(:event, :cancel, eventable: eventable) }
    let(:eventable) { create(:journey) }

    it 'returns an initialized JournalCancel event' do
      expect(described_class.from_event(event)).to be_a(GenericEvent::JourneyCancel)
    end
  end

  describe '.updated_at_range scope' do
    let(:updated_at_from) { Time.zone.yesterday.beginning_of_day }
    let(:updated_at_to) { Time.zone.yesterday.end_of_day }

    it 'returns the expected events' do
      create(:event_move_cancel, updated_at: updated_at_from - 1.second)
      create(:event_move_accept, updated_at: updated_at_to + 1.second)
      on_start_event = create(:event_move_approve, updated_at: updated_at_from)
      on_end_event = create(:event_move_start, updated_at: updated_at_to)

      actual_events = described_class.updated_at_range(updated_at_from, updated_at_to)

      expect(actual_events).to eq([on_start_event, on_end_event])
    end
  end

  describe '.created_at_range scope' do
    let(:created_at_from) { Time.zone.yesterday.beginning_of_day }
    let(:created_at_to) { Time.zone.yesterday.end_of_day }

    it 'returns the expected events' do
      create(:event_move_cancel, created_at: created_at_from - 1.second)
      create(:event_move_accept, created_at: created_at_to + 1.second)
      on_start_event = create(:event_move_approve, created_at: created_at_from)
      on_end_event = create(:event_move_start, created_at: created_at_to)

      actual_events = described_class.created_at_range(created_at_from, created_at_to)

      expect(actual_events).to eq([on_start_event, on_end_event])
    end
  end
end
