# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::PeopleController do
  let(:supplier) { create(:supplier) }
  let!(:application) { create(:application, owner_id: supplier.id) }
  let(:access_token) { create(:access_token, application: application).token }
  let(:response_json) { JSON.parse(response.body) }
  let(:person) { create(:person, :nomis_synced, latest_nomis_booking_id: '1150262') }
  let(:court_cases_from_nomis) do
    OpenStruct.new(
      success?: true,
      court_cases: [
        CourtCase.new.build_from_nomis('id' => '1495077', 'beginDate' => '2020-01-01', 'agency' => { 'agencyId' => 'SNARCC' }),
        CourtCase.new.build_from_nomis('id' => '2222222', 'beginDate' => '2020-01-02', 'agency' => { 'agencyId' => 'SNARCC' }),
      ],
    )
  end

  let(:headers) do
    {
      'CONTENT_TYPE': ApiController::CONTENT_TYPE,
      'Accept': 'application/vnd.api+json; version=2',
      'Authorization' => "Bearer #{access_token}",
    }
  end

  before do
    allow(People::RetrieveCourtCases).to receive(:call).and_return(court_cases_from_nomis)
  end

  context 'when not including the include query param' do
    it 'returns no included relationships' do
      create(:location, nomis_agency_id: 'SNARCC', title: 'Snaresbrook Crown Court', location_type: 'CRT')
      get "/api/v1/people/#{person.id}/court_cases", params: {}, headers: headers

      expect(response_json).not_to include('included')
    end
  end
end