# frozen_string_literal: true

class Location < ApplicationRecord
  NOMIS_AGENCY_TYPES = {
    'INST' => :prison,
    'CRT' => :court
  }.freeze

  has_many :moves_from, class_name: 'Move', foreign_key: :from_location_id
  has_many :moves_to, class_name: 'Move', foreign_key: :to_location_id

  validates :key, presence: true
  validates :title, presence: true
  validates :location_type, presence: true
end
