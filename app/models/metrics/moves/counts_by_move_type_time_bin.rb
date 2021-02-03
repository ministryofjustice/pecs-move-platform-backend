module Metrics
  module Moves
    class CountsByMoveTypeTimeBin
      include BaseMetric
      include Moves
      include TimeBins

      def initialize(supplier: nil)
        setup_metric(
          supplier: supplier,
          label: 'Move counts by move type and time bin',
          file: 'counts_by_move_type_time_bin',
          interval: 5.minutes,
          columns: {
            name: 'move_type',
            field: :itself,
            values: Move.move_types.values << TOTAL,
          },
          rows: {
            name: 'time',
            field: :title,
            values: COMMON_TIME_BINS,
          },
        )
      end

      def calculate_row(row_time_bin)
        apply_time_bin(moves, row_time_bin)
          .group(:move_type)
          .count
          .tap { |row| row.merge!(TOTAL => row.values.sum) }
      end
    end
  end
end
