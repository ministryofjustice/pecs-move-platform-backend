FactoryBot.define do
  factory :generic_event do
    eventable { association(:move) }
    occurred_at { Time.zone.now }
    recorded_at { Time.zone.now }
    notes { 'Flibble' }
    details { {} }
  end

  factory :event_move_accept, parent: :generic_event, class: 'GenericEvent::MoveAccept' do
    eventable { association(:move) }
  end

  factory :event_move_approve, parent: :generic_event, class: 'GenericEvent::MoveApprove' do
    eventable { association(:move) }
    details do
      {
        date: '2020-06-16',
        create_in_nomis: true,
      }
    end
  end

  factory :event_move_cancel, parent: :generic_event, class: 'GenericEvent::MoveCancel' do
    eventable { association(:move) }
    details do
      {
        cancellation_reason: 'made_in_error',
        cancellation_reason_comment: 'It was a mistake',
      }
    end
  end

  factory :event_move_collection_by_escort, parent: :generic_event, class: 'GenericEvent::MoveCollectionByEscort' do
    eventable { association(:move) }
    details do
      {
        vehicle_type: 'cellular',
      }
    end
  end

  factory :event_move_complete, parent: :generic_event, class: 'GenericEvent::MoveComplete' do
    eventable { association(:move) }
  end

  factory :event_move_lockout, parent: :generic_event, class: 'GenericEvent::MoveLockout' do
    eventable { association(:move) }
    details do
      {
        from_location_id: create(:location).id,
        reason: 'no_space',
        authorised_at: Time.zone.now.iso8601,
        authorised_by: 'PMU',
      }
    end
  end

  factory :event_move_lodging_start, parent: :generic_event, class: 'GenericEvent::MoveLodgingStart' do
    eventable { association(:move) }
    details do
      {
        location_id: create(:location).id,
        reason: 'overnight_lodging',
      }
    end
  end

  factory :event_move_lodging_end, parent: :generic_event, class: 'GenericEvent::MoveLodgingEnd' do
    eventable { association(:move) }
    details do
      {
        location_id: create(:location).id,
      }
    end
  end

  factory :event_move_notify_premises_of_arrival_in_30_mins, parent: :generic_event, class: 'GenericEvent::MoveNotifyPremisesOfArrivalIn30Mins' do
    eventable { association(:move) }
  end

  factory :event_move_notify_premises_of_eta, parent: :generic_event, class: 'GenericEvent::MoveNotifyPremisesOfEta' do
    eventable { association(:move) }
    details do
      {
        expected_at: '2020-06-16T10:20:30+01:00',
      }
    end
  end

  factory :event_move_notify_premises_of_expected_collection_time, parent: :generic_event, class: 'GenericEvent::MoveNotifyPremisesOfEta' do
    eventable { association(:move) }
    details do
      {
        expected_at: '2020-06-16T10:20:30+01:00',
      }
    end
  end

  factory :event_move_operation_hmcts, parent: :generic_event, class: 'GenericEvent::MoveOperationHmcts' do
    eventable { association(:move) }
    details do
      {
        authorised_at: Time.zone.now.iso8601,
        authorised_by: 'PMU',
        court_cell_number: '6b',
      }
    end
  end

  factory :event_move_operation_safeguard, parent: :generic_event, class: 'GenericEvent::MoveOperationSafeguard' do
    eventable { association(:move) }
    details do
      {
        authorised_at: Time.zone.now.iso8601,
        authorised_by: 'PMU',
      }
    end
  end

  factory :event_move_operation_tornado, parent: :generic_event, class: 'GenericEvent::MoveOperationTornado' do
    eventable { association(:move) }
    details do
      {
        authorised_at: Time.zone.now.iso8601,
        authorised_by: 'PMU',
      }
    end
  end

  factory :event_move_redirect, parent: :generic_event, class: 'GenericEvent::MoveRedirect' do
    eventable { association(:move) }
    details do
      {
        reason: 'no_space',
        move_type: 'court_appearance',
        to_location_id: create(:location).id,
      }
    end
  end

  factory :event_move_reject, parent: :generic_event, class: 'GenericEvent::MoveReject' do
    eventable { association(:move) }
    details do
      {
        rejection_reason: 'no_space_at_receiving_prison',
        cancellation_reason_comment: 'It was a mistake',
        rebook: false,
      }
    end
  end

  factory :event_move_start, parent: :generic_event, class: 'GenericEvent::MoveStart' do
    eventable { association(:move) }
  end

  factory :event_journey_admit_through_outer_gate, parent: :generic_event, class: 'GenericEvent::JourneyAdmitThroughOuterGate' do
    eventable { association(:journey) }

    details do
      {
        vehicle_reg: Faker::Vehicle.license_plate,
        supplier_personnel_number: SecureRandom.uuid,
      }
    end
  end

  factory :event_journey_arrive_at_outer_gate, parent: :generic_event, class: 'GenericEvent::JourneyArriveAtOuterGate' do
    eventable { association(:journey) }
  end

  factory :event_journey_cancel, parent: :generic_event, class: 'GenericEvent::JourneyCancel' do
    eventable { association(:journey) }
  end

  factory :event_journey_complete, parent: :generic_event, class: 'GenericEvent::JourneyComplete' do
    eventable { association(:journey) }
  end

  factory :event_journey_create, parent: :generic_event, class: 'GenericEvent::JourneyCreate' do
    eventable { association(:journey) }
  end

  factory :event_journey_exit_through_outer_gate, parent: :generic_event, class: 'GenericEvent::JourneyExitThroughOuterGate' do
    eventable { association(:journey) }
  end

  factory :event_journey_handover_to_destination, parent: :generic_event, class: 'GenericEvent::JourneyHandoverToDestination' do
    eventable { association(:journey) }

    details do
      {
        supplier_personnel_number: SecureRandom.uuid,
      }
    end
  end

  factory :event_journey_lockout, parent: :generic_event, class: 'GenericEvent::JourneyLockout' do
    eventable { association(:journey) }
    details do
      {
        from_location_id: create(:location).id,
      }
    end
  end

  factory :event_journey_lodging, parent: :generic_event, class: 'GenericEvent::JourneyLodging' do
    eventable { association(:journey) }
    details do
      {
        to_location_id: create(:location).id,
      }
    end
  end

  factory :event_journey_person_boards_vehicle, parent: :generic_event, class: 'GenericEvent::JourneyPersonBoardsVehicle' do
    eventable { association(:journey) }
    details do
      {
        vehicle_type: 'cellular',
        vehicle_reg: Faker::Vehicle.license_plate,
      }
    end
  end

  factory :event_journey_person_leave_vehicle, parent: :generic_event, class: 'GenericEvent::JourneyPersonLeaveVehicle' do
    eventable { association(:journey) }
  end

  factory :event_journey_ready_to_exit, parent: :generic_event, class: 'GenericEvent::JourneyReadyToExit' do
    eventable { association(:journey) }
  end

  factory :event_journey_reject, parent: :generic_event, class: 'GenericEvent::JourneyReject' do
    eventable { association(:journey) }
  end

  factory :event_journey_start, parent: :generic_event, class: 'GenericEvent::JourneyStart' do
    eventable { association(:journey) }
  end

  factory :event_journey_uncancel, parent: :generic_event, class: 'GenericEvent::JourneyUncancel' do
    eventable { association(:journey) }
  end

  factory :event_journey_uncomplete, parent: :generic_event, class: 'GenericEvent::JourneyUncomplete' do
    eventable { association(:journey) }
  end

  factory :event_journey_update, parent: :generic_event, class: 'GenericEvent::JourneyUpdate' do
    eventable { association(:journey) }
  end

  factory :event_per_court_cell_share_risk_assessment, parent: :generic_event, class: 'GenericEvent::PerCourtCellShareRiskAssessment' do
    eventable { association(:person_escort_record) }
    details do
      {
        location_id: create(:location).id,
      }
    end
  end

  factory :event_per_court_all_documentation_provided_to_supplier, parent: :generic_event, class: 'GenericEvent::PerCourtAllDocumentationProvidedToSupplier' do
    eventable { association(:person_escort_record) }
    details do
      {
        subtype: 'warrant',
        court_location_id: create(:location).id,
      }
    end
  end

  factory :event_per_court_assign_cell_in_custody, parent: :generic_event, class: 'GenericEvent::PerCourtAssignCellInCustody' do
    eventable { association(:person_escort_record) }
    details do
      {
        location_id: create(:location).id,
        court_cell_number: '7b',
      }
    end
  end

  factory :event_per_court_ready_in_custody, parent: :generic_event, class: 'GenericEvent::PerCourtReadyInCustody' do
    eventable { association(:person_escort_record) }
    details do
      {
        location_id: create(:location).id,
      }
    end
  end

  factory :event_per_court_excessive_delay_not_due_to_supplier, parent: :generic_event, class: 'GenericEvent::PerCourtExcessiveDelayNotDueToSupplier' do
    eventable { association(:person_escort_record) }
    details do
      {
        subtype: 'making_prisoner_available_for_loading',
        vehicle_reg: Faker::Vehicle.license_plate,
        location_id: create(:location).id,
        ended_at: Time.zone.now.iso8601,
      }
    end
  end

  factory :event_per_court_return_to_custody_area_from_dock, parent: :generic_event, class: 'GenericEvent::PerCourtReturnToCustodyAreaFromDock' do
    eventable { association(:person_escort_record) }
    details do
      {
        location_id: create(:location).id,
        court_cell_number: '7b',
      }
    end
  end
end
