require 'faye/websocket'
require 'eventmachine'
require 'json'
require "graphql/client"
require "graphql/client/http"

HTTP = GraphQL::Client::HTTP.new("http://localhost:3000/graphql")  

# Fetch latest schema on init, this will make a network request
Schema = GraphQL::Client.load_schema(HTTP)

Client = GraphQL::Client.new(schema: Schema, execute: HTTP)
UpdateInventoryMutation = Client.parse <<-'GRAPHQL'
  mutation(
    $storeName: String!,
    $shoeName: String!,
    $quantity: Int!,
  ) {
    updateInventory(input: {
      storeName: $storeName,
      shoeName: $shoeName,
      quantity: $quantity,
    })
    {
      inventory {
        transactions {
          edges {
            node {
              quantity
            }
          }
        }
      }
      errors
    }
  }
GRAPHQL

EM.run {
  ws = Faye::WebSocket::Client.new('ws://localhost:8080/')

  ws.on :message do |event|
    data = JSON.parse(event.data)
    variables = {
      storeName: data['store'],
      shoeName: data['model'],
      quantity: data['inventory']
    }
    result = Client.query(UpdateInventoryMutation, variables: variables)
    puts result.data.update_inventory.inspect
    
  end
}
