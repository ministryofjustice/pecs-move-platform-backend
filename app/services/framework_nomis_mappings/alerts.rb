module FrameworkNomisMappings
  class Alerts
    attr_reader :prison_number

    def initialize(prison_number:)
      @prison_number = prison_number
    end

    def call
      return [] unless prison_number

      build_mappings.compact
    end

  private

    def imported_alerts
      @imported_alerts ||= NomisClient::Alerts.get([prison_number])
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError, OAuth2::Error => e
      Rails.logger.warn "Importing Framework alert mappings Error: #{e.message}"

      []
    end

    def build_mappings
      imported_alerts.map do |imported_alert|
        next unless imported_alert[:active] == true && imported_alert[:expired] == false

        FrameworkNomisMapping.new(
          raw_nomis_mapping: imported_alert,
          code_type: 'alert',
          code: imported_alert[:alert_code],
          code_description: imported_alert[:alert_code_description],
          comments: imported_alert[:comment],
          creation_date: imported_alert[:created_at],
          expiry_date: imported_alert[:expires_at],
        )
      end
    end
  end
end
