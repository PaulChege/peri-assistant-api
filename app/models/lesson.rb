class Lesson < ApplicationRecord
  belongs_to :student
  validates :time, :duration, presence: :true
end
