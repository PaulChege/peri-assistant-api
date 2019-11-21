# == Schema Information
#
# Table name: students
#
#  id            :integer          not null, primary key
#  name          :string
#  email         :string
#  instrument    :string
#  start_date    :date
#  institution   :string
#  mobile_number :string
#  lesson_day    :integer
#  lesson_time   :time
#  goals         :text
#  user_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryBot.define do 
    factory :student do
        name { Faker::Lorem.word }
        institution { Faker::Lorem.word }
        instrument { Faker::Lorem.word }
        mobile_number { Faker::Lorem.word }
        user_id { Faker::Number.number(10) }
    end
end
