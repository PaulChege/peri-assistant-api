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
    name { Faker::Name.name }
    association :institution
    association :user
    instruments { "Piano" }
    sequence(:mobile_number) { |n| "07#{n.to_s.rjust(8, '0')}" }
    email { Faker::Internet.email }
    lesson_unit_charge { 2000 }
    status { :active }
  end
end
