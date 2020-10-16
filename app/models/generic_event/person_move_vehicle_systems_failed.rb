class GenericEvent
  class PersonMoveVehicleSystemsFailed < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :location_id

    details_attributes :supplier_personnel_numbers, :vehicle_reg, :reported_at, :postcode
    relationship_attributes :location_id
    eventable_types 'Move', 'Person'

    include LocationValidations
    include SupplierPersonnelNumberValidations
    include VehicleRegValidations

    validates :postcode, presence: true, postcode: true
    validates_each :reported_at do |record, attr, value|
      Time.zone.iso8601(value)
    rescue ArgumentError
      record.errors.add(attr, 'must be formatted as a valid ISO-8601 date-time')
    end
  end
end
