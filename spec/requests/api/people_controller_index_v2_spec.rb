# frozen_string_literal: true

require 'rails_helper'

# TODO: this class will be renamed to Api::PeopleController
RSpec.describe Api::PeopleController do
  let(:access_token) { 'spoofed-token' }
  let(:response_json) { JSON.parse(response.body) }
  let(:content_type) { ApiController::CONTENT_TYPE }

  let(:headers) do
    {
      'CONTENT_TYPE': content_type,
      'Accept': 'application/vnd.api+json; version=2',
      'Authorization' => "Bearer #{access_token}",
    }
  end

  describe 'GET /people' do
    let(:schema) { load_yaml_schema('get_people_responses.yaml', version: 'v2') }
    let!(:people) { create_list :person, 2, prison_number: nil }
    let(:params) { {} }

    context 'when there are no params' do
      before { get '/api/people', params: params, headers: headers }

      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns correct attributes' do
        expect(response_json['data'].first['attributes']).to include(
          'first_names',
          'last_name',
          'date_of_birth',
          'gender_additional_information',
          'prison_number',
          'criminal_records_office',
          'police_national_computer',
        )
      end

      it 'returns the correct number of people' do
        expect(response_json['data'].count).to eq(2)
      end
    end

    context 'when prison_numbers is present in query' do
      let(:query) { '?filter[prison_number]=G3239GV,GV345VG' }
      let(:import_from_nomis) { instance_double('People::ImportFromNomis', call: nil) }

      before { allow(People::ImportFromNomis).to receive(:new).and_return(import_from_nomis) }

      it 'updates the person from nomis' do
        get "/api/people#{query}", headers: headers

        expect(People::ImportFromNomis).to have_received(:new).with(%w[G3239GV GV345VG])
        expect(import_from_nomis).to have_received(:call)
      end

      context 'when the prison_number is downcased' do
        let(:query) { '?filter[prison_number]=g3239gv,gv345vg' }

        it 'updates the person from nomis' do
          get "/api/people#{query}", headers: headers

          expect(People::ImportFromNomis).to have_received(:new).with(%w[G3239GV GV345VG])
          expect(import_from_nomis).to have_received(:call)
        end
      end
    end

    describe 'filtering results by police_national_computer' do
      let!(:person) { create(:person, police_national_computer: 'AB/1234567') }
      let(:filters) do
        {
          bar: 'bar',
          police_national_computer: 'AB/1234567',
          foo: 'foo',
        }
      end
      let(:params) { { filter: filters } }

      before { get '/api/people', params: params, headers: headers }

      it 'returns the correct number of people' do
        expect(response_json['data'].size).to eq(1)
      end

      it 'returns the person that matches the filter' do
        expect(response_json).to include_json(data: [{ id: person.id }])
      end
    end

    describe 'filtering results by multiple filters' do
      let!(:person) do
        create(:person, criminal_records_office: 'CRO0105d', police_national_computer: 'AB/00001d')
      end
      let(:filters) do
        {
          bar: 'bar',
          criminal_records_office: 'CRO0105d',
          police_national_computer: 'AB/00001d',
          foo: 'foo',
        }
      end
      let(:params) { { filter: filters } }

      before { get '/api/people', params: params, headers: headers }

      it 'returns the correct number of people' do
        expect(response_json['data'].size).to eq(1)
      end

      it 'returns the person that matches the filter' do
        expect(response_json).to include_json(data: [{ id: person.id }])
      end
    end

    describe 'filtering results by multiple values per filter'  do
      let!(:person1) { create(:person, criminal_records_office: 'CRO0111d') }
      let!(:person2) { create(:person, criminal_records_office: 'CRO0222d') }
      let(:filters) do
        {
          criminal_records_office: 'CRO0111d,CRO0222d',
        }
      end
      let(:params) { { filter: filters } }

      before { get '/api/people', params: params, headers: headers }

      it 'returns the correct number of people' do
        expect(response_json['data'].size).to eq(2)
      end

      it 'returns the person that matches the filter' do
        expect(response_json).to include_json(data: [{ id: person1.id }, { id: person2.id }])
      end
    end

    describe 'paginating results' do
      let!(:people) { create_list :person, 6 }

      let(:meta_pagination) do
        {
          per_page: 5,
          total_pages: 2,
          total_objects: 6,
          links: {
            first: '/api/people?page=1',
            last: '/api/people?page=2',
            next: '/api/people?page=2',
          },
        }
      end

      before { get '/api/people', params: params, headers: headers }

      it_behaves_like 'an endpoint that paginates resources'
    end

    describe 'included relationships' do
      let!(:people) { create_list :person, 2 }

      before { get '/api/people', params: params, headers: headers }

      context 'when the include query param is empty' do
        let(:params) { { include: [] } }

        it 'does not include any relationship' do
          expect(response_json).not_to include('included')
        end
      end

      context 'when include is nil' do
        let(:params) { { include: nil } }

        it 'does not include any relationship' do
          expect(response_json).not_to include('included')
        end
      end

      context 'when including multiple relationships' do
        let(:params) { { include: 'ethnicity,gender,profiles' } }

        it 'includes the relevant relationships' do
          returned_types = response_json['included'].map { |r| r['type'] }.uniq

          expect(returned_types).to contain_exactly('ethnicities', 'genders', 'profiles')
        end
      end

      context 'when including a non existing relationship in a query param' do
        let(:params) { { include: 'gender,non-existent-relationship' } }

        it 'responds with error 400' do
          response_error = response_json['errors'].first

          expect(response_error['title']).to eq('Bad request')
          expect(response_error['detail']).to include('["non-existent-relationship"] is not supported.')
        end
      end
    end

    context 'when not authorized', :with_invalid_auth_headers do
      let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
      let(:detail_401) { 'Token expired or invalid' }

      before { get '/api/people', headers: headers }

      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      before { get '/api/people', headers: headers }

      it_behaves_like 'an endpoint that responds with error 415'
    end
  end
end
