# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::Moves::CountsByStatus do
  subject(:metric) { described_class.new }

  it 'includes the BaseMetric module' do
    expect(described_class.ancestors).to include(Metrics::BaseMetric)
  end

  it 'initializes label' do
    expect(metric.label).to eql(described_class::METRIC[:label])
  end

  describe 'calculate_row' do
    subject(:calculate_row) { metric.calculate_row(nil) }

    before do
      create(:move, :proposed)
      create(:move, :requested)
      create(:move, :requested)
      create(:move, :completed)
    end

    it 'computes the metric' do
      expect(calculate_row).to eql(
        {
          'completed' => 1,
          'proposed' => 1,
          'requested' => 2,
        },
      )
    end
  end
end
