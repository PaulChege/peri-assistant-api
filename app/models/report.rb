# frozen_string_literal: true

# == Schema Information
#
# Table name: reports
#
#  id         :integer          not null, primary key
#  summary    :text             not null
#  start_date :date             not null
#  end_date   :date             not null
#  student_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_reports_on_end_date                    (end_date)
#  index_reports_on_start_date                  (start_date)
#  index_reports_on_start_date_and_end_date     (start_date, end_date)
#  fk_rails_...                                 (student_id)
#
# Foreign Keys
#
#  fk_rails_...  (student_id => students.id)
#

class Report < ApplicationRecord
  belongs_to :student
  
  validates :summary, presence: true
  validates :summary, :start_date, :end_date, presence: true
  validate :end_date_after_start_date
  validate :dates_not_in_future
  
  scope :by_date_range, ->(start_date, end_date) { where(start_date: start_date..end_date) }
  scope :current_period, -> { where('start_date <= ? AND end_date >= ?', Date.current, Date.current) }
  scope :by_student, ->(student_id) { where(student_id: student_id) }
  scope :this_month, -> { where('start_date >= ? AND end_date <= ?', Date.current.beginning_of_month, Date.current.end_of_month) }
  scope :this_year, -> { where('start_date >= ? AND end_date <= ?', Date.current.beginning_of_year, Date.current.end_of_year) }
  scope :recent, -> { order(created_at: :desc) }
  
  private
  
  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?
    
    if end_date <= start_date
      errors.add(:end_date, 'must be after start date')
    end
  end
  
  def dates_not_in_future
    return if start_date.blank? || end_date.blank?
    
    if start_date > Date.current
      errors.add(:start_date, 'cannot be in the future')
    end
    
    if end_date > Date.current
      errors.add(:end_date, 'cannot be in the future')
    end
  end
end
