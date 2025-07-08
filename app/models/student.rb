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
#  institution_id  :integer
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

class Student < ApplicationRecord
  belongs_to :user
  has_many :lessons, dependent: :delete_all
  belongs_to :institution
  validates_presence_of :name, :institution_id, :instrument, :mobile_number

  enum :lesson_day, %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday]

  def self.all_instruments
    ['Violin', 'Piano', 'Viola',
     'Cello', 'Percussion', 'Double Bass',
     'Flute', 'Clarinet', 'Oboe', 'Bassoon', 'Tuba',
     'Trombone', 'Trumpet', 'French Horn']
  end

  def self.search(query)
    where("LOWER(name) LIKE '%#{query}%' OR LOWER(instrument) LIKE '%#{query}%' OR LOWER(mobile_number) LIKE '%#{query}%'")
  end
end
