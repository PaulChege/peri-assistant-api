class Student < ApplicationRecord
  belongs_to :user
  validates_presence_of :name, :institution, :mobile_number
end
