module Api
  class GenericEventsController < ApiController
    PERMITTED_EVENT_PARAMS = [
      :type,
      attributes: [
        :event_type,
        :occurred_at,
        :recorded_at,
        :notes,
        details: {},
      ],
      relationships: {},
    ].freeze

    def create
      GenericEvents::CommonParamsValidator.new(event_params, event_relationships).validate!
      event = event_type.constantize.create!(event_attributes)

      render json: event, status: :created, serializer: ::GenericEventSerializer
    end

  private

    def event_attributes
      {}.tap do |attributes|
        attributes.merge!(event_params.fetch(:attributes, {}))
        attributes.merge!('created_by' => created_by)
        attributes.delete('event_type')
        attributes.merge!('eventable' => eventable) if eventable_params
      end
    end

    def event_params
      params.require(:data).permit(PERMITTED_EVENT_PARAMS).to_h
    end

    def event_relationships
      @event_relationships ||= params.require(:data)[:relationships]
    end

    def eventable_params
      @eventable_params ||= event_relationships[:eventable]
    end

    def eventable
      type = eventable_params.dig('data', 'type')
      id = eventable_params.dig('data', 'id')

      type.singularize.capitalize.constantize.find(id)
    end

    def event_type
      @event_type ||= 'GenericEvent::' + event_params.dig('attributes', 'event_type')
    end

    def created_by
      current_user&.owner&.name || 'unknown'
    end
  end
end