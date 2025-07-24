# frozen_string_literal: true

require 'will_paginate/active_record'

class LessonsController < ApplicationController
  before_action :set_student, except: [:user_lessons]
  before_action :set_lesson, only: %i[update destroy show]

  def index
    now = Time.now.utc
    @past_lessons = @student.lessons.where('date_time < ?', now).order(date_time: :desc).paginate(page: params[:past_page], per_page: 10)
    @upcoming_lessons = @student.lessons.where('date_time >= ?', now).order(date_time: :asc).paginate(page: params[:upcoming_page], per_page: 10)

    json_response({
      past_lessons: {
        lessons: @past_lessons,
        current_page: @past_lessons.current_page,
        total_pages: @past_lessons.total_pages,
        total_entries: @past_lessons.total_entries
      },
      upcoming_lessons: {
        lessons: @upcoming_lessons,
        current_page: @upcoming_lessons.current_page,
        total_pages: @upcoming_lessons.total_pages,
        total_entries: @upcoming_lessons.total_entries
      },
      metadata: {
        currency: current_user.currency,
        student: {
          name: @student.name,
          instruments: @student.instruments
        }
      }
    })
  end

  def create
    @lesson = @student.lessons.new(lesson_params)
    if @lesson.valid?
      @lesson.save!
      json_response(@lesson, :created)
    else
      response = { message: @lesson.errors.full_messages.join(',') }
      json_response(response, :unprocessable_entity)
    end
  rescue ActionController::ParameterMissing => e
    json_response({ message: 'Kindly fill in lesson details' }, :unprocessable_entity)
  end

  def show
    json_response({
      lesson: @lesson,
      metadata: {
        currency: current_user.currency,
        student: {
          name: @student.name,
          instruments: @student.instruments
        }
      }
    })
  end

  def update
    @lesson.assign_attributes(lesson_params)
    if @lesson.valid?
      @lesson.save!
      json_response(@lesson)
    else
      response = { message: @lesson.errors.full_messages.join(',') }
      json_response(response, :unprocessable_entity)
    end
  end

  def destroy
    @lesson.destroy
    response = { message: 'Lesson succesfully deleted.' }
    json_response(response)
  end

  def user_lessons
    start_date = 3.months.ago.beginning_of_day
    end_date = 3.months.from_now.end_of_day
    lessons = Lesson.joins(:student)
      .where(students: { user_id: current_user.id })
      .where('date_time >= ? AND date_time <= ?', start_date, end_date)
      .order(:date_time)

    result = lessons.map do |lesson|
      {
        student: { name: lesson.student.name },
        date_time: lesson.date_time,
        duration: lesson.duration
      }
    end   
    json_response(result)
  end

  private

  def lesson_params
    params.require(:lesson).permit(
      :date_time, :duration, :plan, :status, :charge, :paid, :notes
    )
  end

  def set_student
    @student = current_user.students.find(params[:student_id])
  end

  def set_lesson
    @lesson = @student.lessons.find(params[:id])
  end
end
