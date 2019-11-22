# frozen_string_literal: true

# == Schema Information
#
# Table name: lessons
#
#  id         :integer          not null, primary key
#  student_id :integer
#  day        :integer
#  time       :time
#  duration   :integer
#  plan       :text
#  status     :integer
#  charge     :integer
#  paid       :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Lesson < ApplicationRecord
  belongs_to :student
  validates :day, :time, :duration, presence: :true

  enum day: %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday]
  enum status: %i[attended cancelled missed]
end
