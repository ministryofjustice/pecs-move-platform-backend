RSpec.describe GenericEvent::MoveCancel do
  subject(:generic_event) { build(:event_move_cancel) }

  it_behaves_like 'a move event'

  it 'validates cancellation_reason' do
    expect(generic_event).to validate_inclusion_of(:cancellation_reason).in_array(Move::CANCELLATION_REASONS)
  end

  describe '#cancellation_reason' do
    it 'returns the cancellation_reason from the details' do
      expect(generic_event.cancellation_reason).to eq(generic_event.details['cancellation_reason'])
    end
  end

  describe '#cancellation_reason_comment' do
    it 'returns the cancellation_reason_comment from the details' do
      expect(generic_event.cancellation_reason_comment).to eq(generic_event.details['cancellation_reason_comment'])
    end
  end

  describe '#trigger' do
    before do
      allow(Allocations::RemoveFromNomis).to receive(:call)
    end

    it 'does not persist changes to the eventable' do
      generic_event.trigger
      expect(generic_event.eventable).not_to be_persisted
    end

    it 'sets the eventable `status` to cancelled' do
      expect { generic_event.trigger }.to change { generic_event.eventable.status }.from('requested').to('cancelled')
    end

    it 'sets the eventable `cancellation_reason`' do
      expect { generic_event.trigger }.to change { generic_event.eventable.cancellation_reason }.from(nil).to('made_in_error')
    end

    it 'sets the eventable `cancellation_reason_comment`' do
      expect { generic_event.trigger }.to change { generic_event.eventable.cancellation_reason_comment }.from(nil).to('It was a mistake')
    end

    it 'calls the Allocations::RemoveFromNomis service with the eventable' do
      generic_event.trigger

      expect(Allocations::RemoveFromNomis).to have_received(:call).with(generic_event.eventable)
    end
  end

  describe '.from_event' do
    let(:move) { create(:move) }
    let(:event) do
      create(:event, :cancel, :locations, eventable: move,
                                          details: {
                                            event_params: {
                                              attributes: {
                                                cancellation_reason: 'aaa',
                                                cancellation_reason_comment: 'bbb',
                                                notes: 'foo',
                                              },
                                            },
                                          })
    end

    let(:expected_generic_event_attributes) do
      {
        'id' => nil,
        'eventable_id' => move.id,
        'eventable_type' => 'Move',
        'type' => 'GenericEvent::MoveCancel',
        'notes' => 'foo',
        'created_by' => 'unknown',
        'details' => { 'cancellation_reason' => 'aaa', 'cancellation_reason_comment' => 'bbb' },
        'occurred_at' => eq(event.client_timestamp),
        'recorded_at' => eq(event.client_timestamp),
        'created_at' => be_within(0.1.seconds).of(event.created_at),
        'updated_at' => be_within(0.1.seconds).of(event.updated_at),
      }
    end

    it 'builds a generic_event with the correct attributes' do
      expect(
        described_class.from_event(event).attributes,
      ).to include_json(expected_generic_event_attributes)
    end
  end

  describe '#for_feed' do
    subject(:generic_event) { create(:event_move_cancel, details: details) }

    context 'when the cancellation_reason_comment is present' do
      let(:details) do
        {
          cancellation_reason: 'made_in_error',
          cancellation_reason_comment: 'It was a mistake',
        }
      end

      let(:expected_json) do
        {
          'id' => generic_event.id,
          'type' => 'GenericEvent::MoveCancel',
          'notes' => 'Flibble',
          'created_at' => be_a(Time),
          'updated_at' => be_a(Time),
          'occurred_at' => be_a(Time),
          'recorded_at' => be_a(Time),
          'eventable_id' => generic_event.eventable_id,
          'eventable_type' => 'Move',
          'details' => generic_event.details,
        }
      end

      it 'generates a feed document' do
        expect(generic_event.for_feed).to include_json(expected_json)
      end
    end

    context 'when the cancellation_reason_comment is not present' do
      let(:details) do
        {
          cancellation_reason: 'made_in_error',
        }
      end

      let(:expected_json) do
        {
          'id' => generic_event.id,
          'type' => 'GenericEvent::MoveCancel',
          'notes' => 'Flibble',
          'created_at' => be_a(Time),
          'updated_at' => be_a(Time),
          'occurred_at' => be_a(Time),
          'recorded_at' => be_a(Time),
          'eventable_id' => generic_event.eventable_id,
          'eventable_type' => 'Move',
          'details' => {
            'cancellation_reason' => 'made_in_error',
            'cancellation_reason_comment' => '',
          },
        }
      end

      it 'generates a feed document' do
        expect(generic_event.for_feed).to include_json(expected_json)
      end
    end
  end
end
