# frozen_string_literal: true

# == Schema Information
#
# Table name: students
#
#  id              :integer          not null, primary key
#  name            :string
#  email           :string
#  instruments     :string
#  start_date      :date
#  institution_id  :integer
#  mobile_number   :string
#  date_of_birth   :date
#  goals           :text
#  user_id         :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  schedule        :jsonb            default([])
#  lesson_unit_charge :integer          default(0)
#

class Student < ApplicationRecord
  belongs_to :user
  has_many :lessons, dependent: :delete_all
  belongs_to :institution
  validates_presence_of :name, :institution_id, :instruments, :mobile_number
  validate :instruments_must_be_valid
  validate :date_of_birth_must_be_in_the_past
  validates :mobile_number, format: { with: /\A\d{10}\z/, message: 'must be 10 digits' }, uniqueness: { scope: :user_id }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: 'must be a valid email address' }, uniqueness: { scope: :user_id }
  validate :schedule_must_be_valid

  def self.all_instruments
    %w[Violin Piano Guitar Recorder Viola Cello Percussion Double-Bass Flute Clarinet Oboe Bassoon Tuba Trombone Trumpet French Horn Saxophone Drums Voice]
  end

  # TODO: Replace with search cop
  def self.search(query)
    where("LOWER(name) LIKE '%#{query}%' OR LOWER(instruments) LIKE '%#{query}%' OR LOWER(mobile_number) LIKE '%#{query}%'")
  end

  def instruments_must_be_valid
    if instruments.present? && instruments.split(',').any? { |instrument| !self.class.all_instruments.include?(instrument) }
      errors.add(:instruments, 'must be one or a list of valid instruments')
    end
  end

  def date_of_birth_must_be_in_the_past
    if date_of_birth.present? && date_of_birth > Date.today
      errors.add(:date_of_birth, 'must be in the past')
    end
  end

  def schedule_must_be_valid
    if schedule.present?
      puts schedule.inspect
      valid = schedule.all? do |day|
        day.keys.all? { |key| %w[day start_time duration].include?(key) }
      end
      errors.add(:schedule, 'must be a valid schedule') unless valid
    end
  end
end
