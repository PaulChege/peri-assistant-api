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
  validates :date_time, :duration, presence: true
  
  enum :status, %i[attended cancelled missed]
  validate :cannot_attend_future_lesson
  validate :no_time_conflict

  private

  def cannot_attend_future_lesson
    if status == 'attended' && date_time.present? && date_time > Time.now.utc
      errors.add(:status, 'cannot be marked as attended for a future lesson')
    end

    if status == 'missed' && date_time.present? && date_time > Time.now.utc
      errors.add(:status, 'cannot be marked as missed for a future lesson')
    end
  end

  def no_time_conflict
    return if date_time.blank? || duration.blank?
    end_time = date_time + duration.minutes
    overlapping = Lesson.where(student_id: student_id)
      .where.not(id: id)
      .where('date_time < ? AND (date_time + (duration * interval \'1 minute\')) > ?', end_time, date_time)
    if overlapping.exists?
      errors.add(:base, 'Lesson time conflicts with another lesson')
    end
  end
end
