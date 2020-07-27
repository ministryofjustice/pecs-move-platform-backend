require 'rails_helper'

RSpec.describe Allocations::CreateInNomis do
  context 'when move is valid' do
    subject(:create_transfer_in_nomis) { described_class.call(move) }

    let(:move) do
      create(
        :move,
        date: move_date,
        from_location: create(:location, nomis_agency_id: from_nomis_agency_id),
        to_location: create(:location, nomis_agency_id: to_nomis_agency_id),
      )
    end

    let(:move_date) { Date.parse('2099-07-27') }
    let(:from_nomis_agency_id) { 'PVI' }
    let(:to_nomis_agency_id) { 'HLI' }
    let(:booking_id) { 123 }
    let(:response_body) { { 'id' => 123 }.to_json }

    before do
      allow(NomisClient::Allocations).to receive(:post)
                                     .and_return(instance_double('OAuth2::Response', status: nomis_response_status, body: response_body))
      move.person.update(latest_nomis_booking_id: booking_id)
    end

    context 'when Nomis return 201 success' do
      let(:nomis_response_status) { 201 }
      let(:nomis_client_args) do
        {
          booking_id: booking_id,
          body_params: {
            'fromPrisonLocation': from_nomis_agency_id,
            'toPrisonLocation': to_nomis_agency_id,
            'escortType': 'PECS',
            'scheduledMoveDateTime': '2099-07-27T00:00:00',
          },
        }
      end

      it 'creates the prison transfer event in Nomis' do
        create_transfer_in_nomis

        expect(NomisClient::Allocations).to have_received(:post).with(nomis_client_args)
      end

      it 'updates the nomis_event_id' do
        create_transfer_in_nomis

        expect(move.nomis_event_id).to eq 123
      end

      it 'returns debugging information' do
        expect(create_transfer_in_nomis).to include(
          request_params: nomis_client_args,
          response_body: response_body,
          response_status: 201,
        )
      end
    end

    context 'when Nomis returns an error' do
      let(:nomis_response_status) { 400 }

      it 'does NOT set nomis_event_id' do
        create_transfer_in_nomis

        expect(move.nomis_event_id).to be_nil
      end

      it 'returns debugging information' do
        expect(create_transfer_in_nomis).to include(
          response_status: 400,
        )
      end
    end
  end
end
