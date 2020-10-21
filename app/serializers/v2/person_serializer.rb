# frozen_string_literal: true

module V2
  class PersonSerializer
    include JSONAPI::Serializer

    set_type :people

    attributes(
      :first_names,
      :last_name,
      :date_of_birth,
      :gender_additional_information,
      :prison_number,
      :criminal_records_office,
      :police_national_computer,
    )

    has_one :ethnicity, serializer: EthnicitySerializer
    has_one :gender, serializer: GenderSerializer
    has_many :profiles, serializer: ProfileSerializer
    has_many :events, serializer: GenericEventSerializer do |object|
      object.generic_events.applied_order
    end

    SUPPORTED_RELATIONSHIPS = %w[ethnicity gender profiles].freeze
  end
end
