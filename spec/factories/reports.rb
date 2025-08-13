# frozen_string_literal: true

FactoryBot.define do
  factory :report do
    summary { Faker::Lorem.paragraph(sentence_count: 3) }
    start_date { Date.current }
    end_date { Date.current + 1.week }
    association :student
  end
end
