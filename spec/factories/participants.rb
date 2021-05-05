FactoryBot.define do
  factory :participant do
    association :user, factory: :user
    association :course, factory: :course
  end
end
