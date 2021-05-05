FactoryBot.define do
  factory :user do
  
    mail {"test@tester-mail.com"}
    verified {true}
    password {123}
  end
end
