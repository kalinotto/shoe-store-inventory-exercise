module Types
  class MutationType < Types::BaseObject
    field :update_inventory, mutation: Mutations::UpdateInventory
  end
end
