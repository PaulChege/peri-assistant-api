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

class Lesson < ApplicationRecord
  belongs_to :student
  validates :day, :time, :duration, presence: :true

  enum status: %i[attended cancelled missed]
end
