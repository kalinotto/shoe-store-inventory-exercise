FactoryBot.define do
  factory :transaction do
    association :inventory
    quantity { -1 }
  end
end