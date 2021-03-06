# frozen_string_literal: true

class Supplier < ApplicationRecord
  has_many :supplier_locations
  has_many :locations, through: :supplier_locations
  has_many :subscriptions, dependent: :destroy
  has_many :moves, dependent: :restrict_with_exception

  # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :name, :key, presence: true, uniqueness: true
  # rubocop:enable Rails/UniqueValidationWithoutIndex

  before_validation :ensure_key_has_value

  def ==(other)
    key == other.key
  end

  def for_feed
    {
      'supplier' => key,
    }
  end

private

  def ensure_key_has_value
    self.key = name.downcase.gsub(' ', '_') if key.blank? && name.present?
  end
end
