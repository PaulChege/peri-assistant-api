# frozen_string_literal: true

class LessonGenerationJob < ApplicationJob
  queue_as :default

  rescue_from StandardError do |exception|
    logger.error "Error in LessonGenerationJob: #{exception.message}"
  end

  def perform(student_id)
    student = Student.find_by(id: student_id)
    return unless student
    LessonGenerationService.new(student).generate_upcoming_lessons!
  end
end 