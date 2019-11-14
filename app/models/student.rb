# == Schema Information
#
# Table name: students
#
#  id            :integer          not null, primary key
#  name          :string
#  email         :string
#  instrument    :string
#  start_date    :date
#  institution   :string
#  mobile_number :string
#  lesson_day    :string
#  lesson_time   :time
#  goals         :text
#  user_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Student < ApplicationRecord
  belongs_to :user
  has_many :lessons
  validates_presence_of :name, :institution, :instrument, :mobile_number


  def self.all_instruments
    ["Violin", "Piano", "Viola", "Cello", "Percussion", "Double Bass",
  "Flute", "Clarinet","Oboe", "Bassoon","Tuba","Trombone","Trumpet","French Horn"]
  end
end
