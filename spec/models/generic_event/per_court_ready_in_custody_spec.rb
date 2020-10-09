RSpec.describe GenericEvent::PerCourtReadyInCustody do
  subject(:generic_event) { build(:event_per_court_ready_in_custody) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[PersonEscortRecord]) }

  it_behaves_like 'an event requiring a location', :location_id
end