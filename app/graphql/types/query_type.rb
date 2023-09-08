module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    field :shoes, Types::ShoeType.connection_type, null: false
    def shoes
      Shoe.all
    end

    field :stores, Types::StoreType.connection_type, null: false
    def stores
      Store.all
    end

    # Allows looking up a shoe to check it's inventory across stores, sorted by default
    # Useful for determining which stores have excess stock of a shoe and which are lacking
    field :inventory_by_shoe, Types::InventoryType.connection_type do
      argument :shoe_model, String
    end
    def inventory_by_shoe(shoe_model:)
      shoe = Shoe.where(model: shoe_model).first

      return nil unless shoe

      Inventory.where(shoe_id: shoe.id).order(quantity: :ASC)
    end
  end
end
