FactoryBot.define do 
    factory :user do
        name {Faker::Name.name}
        email {'foo@foo.com'}
        password {'foobar'}
    end
end