# frozen_string_literal: true

module Types
  class InventoryType < Types::BaseObject
    field :id, ID, null: false
    field :shoe_id, Integer
    field :store_id, Integer
    field :quantity, Integer
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :store, Types::StoreType, null: false
    def store
      dataloader.with(Sources::Association, :store).load(object)
    end
  
    field :shoe, Types::ShoeType, null: false
    def shoe
      dataloader.with(Sources::Association, :shoe).load(object)
    end
  
    field :transactions, Types::TransactionType.connection_type, null: false
    def transactions
      dataloader.with(Sources::Association, :transactions).load(object)
    end
  end
end
