# frozen_string_literal: true

require 'will_paginate/active_record'

class LessonFilterService
  def initialize(base, institution_filter: nil, past_page: 1, upcoming_page: 1)
    @base = base
    @institution_filter = institution_filter
    @past_page = past_page
    @upcoming_page = upcoming_page
    @now = Time.now.utc
  end

  def call
    {
      past_lessons: build_past_lessons_response,
      upcoming_lessons: build_upcoming_lessons_response,
      metadata: build_metadata
    }.compact
  end

  private

  attr_reader :base, :institution_filter, :past_page, :upcoming_page, :now

  def build_past_lessons_response
    lessons = filtered_lessons.where('date_time < ?', now).order(date_time: :desc).paginate(page: past_page, per_page: 10)
    
    {
      lessons: include_student_and_institution_info(lessons),
      current_page: lessons.current_page,
      total_pages: lessons.total_pages,
      total_entries: lessons.total_entries
    }
  end

  def build_upcoming_lessons_response
    lessons = filtered_lessons.where('date_time >= ?', now).order(date_time: :asc).paginate(page: upcoming_page, per_page: 10)
    
    {
      lessons: include_student_and_institution_info(lessons),
      current_page: lessons.current_page,
      total_pages: lessons.total_pages,
      total_entries: lessons.total_entries
    }
  end

  def filtered_lessons
    if institution_filter.present?
      base.lessons.joins(student: :institution).where(institutions: { name: institution_filter })
    else
      base.lessons
    end
  end

  def build_metadata
    return nil unless base.is_a?(Student)
    
    {
      currency: base.user.currency,
      student: {
        name: base.name,
        instruments: base.instruments,
        schedule: base.schedule
      }
    }
  end

  def include_student_and_institution_info(lessons)
    return lessons unless base.is_a?(User)
    
    lessons.includes(student: :institution).map do |lesson|
      lesson.as_json.merge(
        student: {
          id: lesson.student.id,
          name: lesson.student.name,
          instruments: lesson.student.instruments,
          schedule: lesson.student.schedule
        },
        institution: {
          id: lesson.student.institution.id,
          name: lesson.student.institution.name
        }
      )
    end
  end
end 