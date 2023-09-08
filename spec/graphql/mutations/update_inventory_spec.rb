require 'rails_helper'

module Mutations
  module Books
    RSpec.describe UpdateInventory, type: :request do
      describe '.resolve' do

        before do
          @store = create(:store)
          @shoe = create(:shoe)
        end

        context 'without an existing inventory record' do
          it 'creates an inventory record' do
            expect {
              post '/graphql', params: { query: query(quantity: 10) }
            }.to change { Inventory.count }.by(1)

            json = JSON.parse(response.body)
            data = json['data']['updateInventory']['inventory']

            expect(data).to include(
              'id'       => be_present,
              'storeId' => @store.id,
              'shoeId'  => @shoe.id,
              'quantity' => 10
            )

            expect(Inventory.count).to be 1
          end

          it 'does not create a transaction' do
            expect {
              post '/graphql', params: { query: query(quantity: 10) }
            }.not_to change { Transaction.count }
          end
        end

        context 'with an existing inventory record' do
          before do
            @inventory = create(:inventory, store: @store, shoe: @shoe)
          end

          it 'updates the inventory record' do
            expect {
              post '/graphql', params: { query: query(quantity: 9) }
            }.not_to change { Inventory.count }

            json = JSON.parse(response.body)
            data = json['data']['updateInventory']['inventory']

            expect(data).to include(
              'id'       => be_present,
              'storeId' => @store.id,
              'shoeId'  => @shoe.id,
              'quantity' => 9
            )

            expect(@inventory.reload).to have_attributes(
              'store_id' => @store.id,
              'shoe_id'  => @shoe.id,
              'quantity' => 9
            )
          end

          it 'creates a postive transaction when the quantity is reduced' do
            expect {
              post '/graphql', params: { query: query(quantity: 9) }
            }.to change { Transaction.count }.by(1)

            json = JSON.parse(response.body)
            data = json['data']['updateInventory']['inventory']['transactions']['edges']

            expect(data.length).to be 1
            expect(data.first['node']['quantity']).to be 1
          end

          it 'creates a negative transaction when the quantity is increased' do
            expect {
              post '/graphql', params: { query: query(quantity: 11) }
            }.to change { Transaction.count }.by(1)

            json = JSON.parse(response.body)
            data = json['data']['updateInventory']['inventory']['transactions']['edges']

            expect(data.length).to be 1
            expect(data.first['node']['quantity']).to be -1
          end
        end
      end

      def query(quantity:)
        <<~GQL
          mutation{
            updateInventory(
              input: {
                storeName: "#{@store.name}"
                shoeName: "#{@shoe.model}"
                quantity: #{quantity} 
              }
            )
            {
              inventory {
                id
                storeId
                shoeId
                quantity
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
        GQL
      end
    end
  end
end