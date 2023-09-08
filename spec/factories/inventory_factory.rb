FactoryBot.define do
  factory :inventory do
    association :store
    association :shoe
    quantity { 10 }
  end
end