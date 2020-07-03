# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkQuestion do
  it { is_expected.to validate_presence_of(:key) }
  it { is_expected.to validate_presence_of(:section) }
  it { is_expected.to validate_presence_of(:question_type) }
  it { is_expected.to validate_inclusion_of(:question_type).in_array(%w[radio checkbox text textarea]) }

  it { is_expected.to belong_to(:framework) }
  it { is_expected.to belong_to(:parent).optional }

  it { is_expected.to have_many(:dependents) }
  it { is_expected.to have_many(:flags) }
end