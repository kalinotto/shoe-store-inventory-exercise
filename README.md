# README

This is a Rails/GraphQL backend to handle inventory management for the `shoe-store`` exercise.

## Overview

https://www.loom.com/share/390c5011651243be8400c92cdce1ce99?sid=37af9e64-2716-45b0-8a20-bbbca90ab6b2

## Set-up

This backend relies on GraphQL for communication, and does not integrate directly with the websocket server provided. Instead, it uses a script to catch the websocket messages and convert them to GraphQL mutations.

1. Start the `shoe-store` websocket server with `websocketd --port=8080 ruby inventory.rb` from the `shoe-store` repository
2. Setup the rails server with `bundle install` and `rails db:seed` (Must seed the DB to initialize stores and shoes in the database)
3. Start this server with `rails s`
4. Finally, start the script to catch websocket messages and send GraphQL requests with `ruby script.rb`

The script will start to consume the messages and send GraphQL mutation requests to the rails server. You can stop the script at any time if you wish to inspect the state of the inventory without changes constantly being made.

## Usage

In order to view the inventory, navigate to `http://localhost:3000/graphiql` while the server is running. You can query for the inventory of each store with a query like the following:

```
query {
  stores {
    edges {
      node {
        id
        name
        inventory {
          edges {
            node {
              shoe {
                id
                model
              }
              quantity
            }
          }
        }
      }
    }
  }
}
```

There is another query available intended to support decisions for migrating inventory of a given shoe from one store to another.

```
query {
  inventoryByShoe(shoeModel: "ADERI") {
    edges{
      node{
        store {
          name
        }
        quantity
      }
    }
  }
}
```

Finally, you can manually update the inventory of a given store/shoe with the following mutation:

```
mutation {
  updateInventory(input: {
    storeName: "ALDO Centre Eaton", shoeName: "ADERI", quantity: 11
  })
  {
    inventory {
      quantity
    }
    errors
  }
}
```

## Database Schema

The database uses 4 tables to track inventory and sales. The `stores` and `shoes` table indicate the stores and shoe models available in the system. A join table `inventories` links each `store` to a `shoe` and has a `quantity` field expressing how many shoes of a given model are in a given store. Finally, the `transactions` table keeps track of changes to an inventory (useful for seeing sale data over time, and financial calculations if we included prices).

See schema here:
https://dbdiagram.io/d/64fa9c5a02bd1c4a5e2fcb6f

## Assumptions

Because of the way the messages are emitted, I made the following assumptions:

- The first message for a given store/shoe combination initializes the inventory at that amount, and does not count as a sale
- Following messages for a store/shoe combination indicates a sale equivalent to the difference in quantity
  - eg: if the new amount is lower, we consider it a sale (logged in the `transaction` table as a positive quantity) and if the new amount is higher, we consider it a return (negative quantity in `transaction`)
