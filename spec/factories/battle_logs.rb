FactoryBot.define do
  factory :battle_log do
    association :turn
    game { turn.game }
    event_type { "attack" }
    details { {} }
  end
end
