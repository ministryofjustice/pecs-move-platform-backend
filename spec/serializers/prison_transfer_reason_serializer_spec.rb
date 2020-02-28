# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PrisonTransferReasonSerializer do
  subject(:serializer) { described_class.new(reason) }

  let(:reason) { create :prison_transfer_reason }
  let(:result) { JSON.parse(ActiveModelSerializers::Adapter.create(serializer).to_json).deep_symbolize_keys }

  it 'contains a type property' do
    expect(result[:data][:type]).to eql 'prison_transfer_reasons'
  end

  it 'contains an `id` property' do
    expect(result[:data][:id]).to eql reason.id
  end

  it 'contains a `key` attribute' do
    expect(result[:data][:attributes][:key]).to eql 'reason_other'
  end

  it 'contains a `title` attribute' do
    expect(result[:data][:attributes][:title]).to eql 'Other'
  end
end
