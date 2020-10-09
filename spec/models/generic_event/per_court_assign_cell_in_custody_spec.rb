RSpec.describe GenericEvent::PerCourtAssignCellInCustody do
  subject(:generic_event) { build(:event_per_court_assign_cell_in_custody) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[PersonEscortRecord]) }
  it { is_expected.to validate_presence_of(:court_cell_number) }

  it_behaves_like 'an event requiring a location', :location_id
end