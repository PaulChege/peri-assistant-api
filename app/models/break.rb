# frozen_string_literal: true

# == Schema Information
#
# Table name: breaks
#
#  id            :integer          not null, primary key
#  start_date    :date             not null
#  end_date      :date             not null
#  breakable_type :string           not null
#  breakable_id  :integer          not null
#  user_id       :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Break < ApplicationRecord
  belongs_to :breakable, polymorphic: true
  belongs_to :user
  
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :user_id, presence: true
  validate :end_date_after_start_date
  validate :no_overlapping_breaks, on: :create
  validate :break_period_in_future
  
  scope :active, -> { where('end_date >= ?', Date.current) }
  scope :inactive, -> { where('end_date < ?', Date.current) }
  scope :current, -> { where('start_date <= ? AND end_date >= ?', Date.current, Date.current) }
  
  after_create :trigger_lesson_regeneration
  after_update :trigger_lesson_regeneration, if: :break_dates_changed?
  after_destroy :trigger_lesson_regeneration
  
  private
  
  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?
    
    if end_date <= start_date
      errors.add(:end_date, 'must be after start date')
    end
  end
  
  def no_overlapping_breaks
    return if breakable.blank? || start_date.blank? || end_date.blank?
    
    overlapping_breaks = breakable.breaks.where(
      '(start_date <= ? AND end_date >= ?) OR (start_date <= ? AND end_date >= ?) OR (start_date >= ? AND end_date <= ?)',
      end_date, start_date, start_date, start_date, start_date, end_date
    )
    
    if overlapping_breaks.exists?
      errors.add(:base, 'Break period overlaps with existing break')
    end
  end
  
  def break_period_in_future
    return if start_date.blank? || end_date.blank?
    
    # Check if at least part of the break period is in the future
    if end_date < Date.current
      errors.add(:base, 'Break period must be at least partially in the future')
    end
  end

  def trigger_lesson_regeneration
    case breakable
    when Institution
      # Run job for all students of the user who are in that institution
      students_in_institution = Student.joins(:user)
                                      .where(institution: breakable, user_id: user_id)
      students_in_institution.find_each do |student|
        LessonGenerationJob.perform_later(student.id)
      end
    when Student
      # Run job just for that student
      LessonGenerationJob.perform_later(breakable.id)
    when User
      # Run job for all students of that user
      breakable.students.find_each do |student|
        LessonGenerationJob.perform_later(student.id)
      end
    end
  end

  def break_dates_changed?
    saved_change_to_start_date? || saved_change_to_end_date?
  end
end 