# frozen_string_literal: true

# == Schema Information
#
# Table name: lessons
#
#  id         :integer          not null, primary key
#  student_id :integer
#  time       :time
#  duration   :integer
#  plan       :text
#  status     :integer
#  charge     :integer
#  paid       :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  day        :date
#

FactoryBot.define do
  factory :lesson do
    day { Date.today }
    time { '12:00' }
    duration { Faker::Number.number(digits: 2) }
    student_id { Faker::Number.number(digits: 2) }
  end
end
