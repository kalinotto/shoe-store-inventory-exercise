# frozen_string_literal: true

module Types
  class StoreType < Types::BaseObject
    field :id, ID, null: false
    field :name, String
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :inventory, Types::InventoryType.connection_type, null: false
    def inventory
      dataloader.with(Sources::Association, :inventories).load(object)
    end
  end
end
