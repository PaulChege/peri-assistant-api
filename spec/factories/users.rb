# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string
#  email           :string
#  password_digest :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryBot.define do 
    factory :user do
        name {Faker::Name.name}
        email {'foo@foo.com'}
        password {'foobar'}
    end
end
