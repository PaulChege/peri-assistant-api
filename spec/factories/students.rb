FactoryBot.define do 
    factory :student do
        name { Faker::Lorem.word }
        institution { Faker::Lorem.word }
        instrument { Faker::Lorem.word }
        mobile_number { Faker::Lorem.word }
        user_id { Faker::Number.number(10) }
    end
end