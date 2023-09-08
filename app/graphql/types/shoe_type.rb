# frozen_string_literal: true

module Types
  class ShoeType < Types::BaseObject
    field :id, ID, null: false
    field :model, String
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
