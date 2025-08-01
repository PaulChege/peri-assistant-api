# frozen_string_literal: true

# == Schema Information
#
# Table name: students
#
#  id              :integer          not null, primary key
#  name            :string
#  email           :string
#  instrument      :string
#  start_date      :date
#  institution     :string
#  mobile_number   :string
#  date_of_birth   :date
#  lesson_day      :integer
#  lesson_time     :time
#  goals           :text
#  user_id         :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  lesson_duration :integer
#  lesson_charge   :integer
#

FactoryBot.define do
  factory :student do
    name { Faker::Lorem.word }
    association :institution
    instruments { Faker::Lorem.word }
    mobile_number { Faker::Lorem.word }
    user_id { Faker::Number.number(digits: 2) }
    lesson_unit_charge { 2000 }
    status { :active }
  end
end
