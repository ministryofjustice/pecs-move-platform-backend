# frozen_string_literal: true

class NationalitySerializer < ActiveModel::Serializer
  attributes :id, :key, :title, :description
end
