FactoryBot.define do
  factory :course do
    name { "Pimp Your Math" }
    private { true }
    # association :participants, factory: :participant
  end
end
