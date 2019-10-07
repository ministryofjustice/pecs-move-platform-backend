# frozen_string_literal: true

module Moves
  class Sweeper
    attr_accessor :items, :date, :locations

    def initialize(locations, date, items)
      self.locations = locations
      self.date = date
      self.items = items
    end

    def call
      cancel_outdated_moves!
    end

    private

    def cancel_outdated_moves!
      outdated_moves = Move.where(
        date: date,
        from_location_id: locations.map(&:id)
      ).where.not(
        nomis_event_id: current_nomis_event_ids
      )
      outdated_moves.update(status: Move::MOVE_STATUS_CANCELLED)
    end

    def current_nomis_event_ids
      items.map { |item| item[:nomis_event_id] }
    end
  end
end