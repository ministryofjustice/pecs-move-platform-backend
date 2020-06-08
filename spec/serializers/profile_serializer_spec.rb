# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProfileSerializer do
  subject(:serializer) { described_class.new(profile) }

  let(:profile) { create :profile }
  let(:adapter_options) { {} }
  let(:result) { JSON.parse(ActiveModelSerializers::Adapter.create(serializer, adapter_options).to_json).deep_symbolize_keys }

  it 'contains type property' do
    expect(result[:data][:type]).to eql 'profiles'
  end

  it 'contains id property' do
    expect(result[:data][:id]).to eql profile.id
  end

  it 'contains first_names attribute' do
    expect(result[:data][:attributes][:first_names]).to eql profile.first_names
  end

  it 'contains last_name attribute' do
    expect(result[:data][:attributes][:last_name]).to eql profile.last_name
  end

  describe '#assessment_answers' do
    let(:risk_alert_type) { create :assessment_question, :risk }
    let(:health_alert_type) { create :assessment_question, :health }
    let(:court_type) { create :assessment_question, :court }

    let(:risk_alert) do
      {
        title: risk_alert_type.title,
        comments: 'Former miner',
        assessment_question_id: risk_alert_type.id,
      }
    end

    let(:health_alert) do
      {
        title: health_alert_type.title,
        comments: 'Needs something for a headache',
        assessment_question_id: health_alert_type.id,
      }
    end

    let(:court) do
      {
        title: court_type.title,
        comments: 'Only speaks Spanish',
        assessment_question_id: court_type.id,
      }
    end

    before do
      profile.assessment_answers = [
        risk_alert,
        health_alert,
        court,
      ]
      profile.save!
    end

    it 'contains an `assessment_answers` nested collection' do
      expect(result[:data][:attributes][:assessment_answers].map do |alert|
        alert[:title]
      end).to match_array [risk_alert_type.title, health_alert_type.title, court_type.title]
    end
  end

  describe '#identifiers' do
    let(:profile_identifiers) do
      [
        {
          value: 'ABC123456',
          identifier_type: 'police_national_computer',
        },
        {
          value: 'XYZ123456',
          identifier_type: 'prison_number',
        },
      ]
    end

    before do
      profile.profile_identifiers = profile_identifiers
      profile.save!
    end

    it 'contains two identifiers' do
      expect(result[:data][:attributes][:identifiers]).to eql profile_identifiers
    end
  end

  describe 'ethnicity' do
    let(:adapter_options) { { include: { ethnicity: %I[key title description] } } }
    let(:ethnicity) { profile&.ethnicity }
    let(:expected_json) do
      [
        {
          id: ethnicity&.id,
          type: 'ethnicities',
          attributes: {
            key: ethnicity&.key,
            title: ethnicity&.title,
            description: ethnicity&.description,
          },
        },
      ]
    end

    it 'contains an included ethnicity' do
      expect(result[:included]).to(include_json(expected_json))
    end
  end

  describe 'gender' do
    before do
      profile.update(gender_additional_information: gender_additional_information)
    end

    let(:adapter_options) { { include: { gender: %I[title description] } } }
    let(:gender) { profile&.gender }
    let(:gender_additional_information) { 'more info about the profile' }
    let(:expected_json) do
      [
        {
          id: gender&.id,
          type: 'genders',
          attributes: {
            title: gender&.title,
            description: gender&.description,
          },
        },
      ]
    end

    it 'contains an included gender' do
      expect(result[:included]).to(include_json(expected_json))
    end

    it 'contains gender_additional_information' do
      expect(result[:data][:attributes][:gender_additional_information]).to eql gender_additional_information
    end
  end
end