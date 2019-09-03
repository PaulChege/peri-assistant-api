class Student < ApplicationRecord
  belongs_to :user
  has_many :lessons
  validates_presence_of :name, :institution, :mobile_number
end
