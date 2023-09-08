class Mutations::UpdateInventory < Mutations::BaseMutation
  null true
  argument :store_name, String, "Name of the store whose inventory is being updated."
  argument :shoe_name, String, "Name of the shoe whose inventory is being updated."
  argument :quantity, Int, "Integer representing the number of shoes in the store."

  field :inventory, Types::InventoryType, null: true
  field :errors, [String], null: false

  def resolve(store_name:, shoe_name:, quantity:)
    errors = Array.new

    store = Store.where(name: store_name).first
    shoe = Shoe.where(model: shoe_name).first

    errors.push("Unable to find store with name #{store_name}") unless store
    errors.push("Unable to find shoe with name #{shoe_name}") unless shoe
    
    if errors.length > 0
      return {
        inventory: nil,
        errors: errors
      }
    end

    inventory = Inventory.where(store_id: store.id, shoe_id: shoe.id).first

    if inventory
      if inventory.quantity === quantity
        return {
          inventory: inventory,
          errors: ["Attempting to update inventory without changing quantity"]
        }
      end


      begin
        transaction = inventory.transactions.create(quantity: inventory.quantity - quantity)
        inventory.update(quantity: quantity)

        if quantity < 10
          # this is where alerting would go
          puts "#{store_name} is running low on shoe model #{shoe_name}! Remaining stock: #{quantity}"
        end
      rescue => e
        return {
          inventory: inventory,
          errors: [e.message]
        }
      end

      return {
        inventory: inventory,
        errors: []
      }
    else
      new_inventory = Inventory.new(store_id: store.id, shoe_id: shoe.id, quantity: quantity)

      if new_inventory.save
        return {
          inventory: new_inventory,
          errors: []
        }
      else
        return {
          inventory: nil,
          errors: new_inventory.errors.full_messages
        }
      end
    end
  end
end