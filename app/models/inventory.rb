class Inventory < ApplicationRecord
  belongs_to :shoe
  belongs_to :store

  has_many :transactions
end
