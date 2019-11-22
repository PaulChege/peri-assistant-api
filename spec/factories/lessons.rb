# frozen_string_literal: true

FactoryBot.define do
  factory :lesson do
    day { 'Monday' }
    time { '12:00' }
    duration { Faker::Number.number(2) }
    student_id { Faker::Number.number(10) }
  end
end
