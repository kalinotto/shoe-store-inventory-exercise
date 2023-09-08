# frozen_string_literal: true

module Types
  class TransactionType < Types::BaseObject
    field :id, ID, null: false
    field :inventory_id, Integer
    field :quantity, Integer
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
