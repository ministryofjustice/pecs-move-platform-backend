# frozen_string_literal: true

class PersonEscortRecordsSerializer
  include JSONAPI::Serializer
  include JSONAPI::ConditionalRelationships

  set_type :person_escort_records

  has_many_if_included :flags, serializer: FrameworkFlagsSerializer, &:framework_flags

  attributes :created_at, :updated_at, :completed_at, :amended_at, :confirmed_at, :nomis_sync_status, :handover_details, :handover_occurred_at

  attribute :status do |object|
    object.status == 'unstarted' ? 'not_started' : object.status
  end

  meta do |object|
    { section_progress: object.section_progress }
  end
end
