class PersonEscortRecordSerializer < ActiveModel::Serializer
  belongs_to :profile, record_type: :profile
  belongs_to :move, record_type: :move
  belongs_to :framework, record_type: :framework
  has_many :framework_responses, serializer: FrameworkResponseSerializer, key: :responses
  has_many :framework_flags, key: :flags

  attributes :version, :status, :confirmed_at, :created_at

  meta do
    { section_progress: object.section_progress }
  end

  def version
    object.framework.version
  end

  def framework_flags
    object.framework_flags.includes(framework_question: :dependents)
  end

  def framework_responses
    object.framework_responses.includes(:framework_flags, :framework_nomis_mappings, framework_question: [:framework, dependents: :dependents])
  end

  def status
    if object.status == 'unstarted'
      'not_started'
    else
      object.status
    end
  end

  SUPPORTED_RELATIONSHIPS = %w[
    move
    framework
    profile.person
    responses.question
    responses.nomis_mappings
    responses.question.descendants.**
    flags
  ].freeze
end
