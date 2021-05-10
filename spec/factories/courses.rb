FactoryBot.define do
  factory :course do
    name { "Pimp Your Math" }
    public { true }

    association :super_admin, factory: :user
  end
end
