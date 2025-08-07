# frozen_string_literal: true

class LessonsController < ApplicationController
  before_action :set_student, only: [:index]
  before_action :set_lesson, only: %i[update destroy show]

  def index
    base = @student.nil? ? current_user : @student 
    
    result = LessonFilterService.new(
      base,
      institution_filter: params[:institution_filter],
      past_page: params[:past_page],
      upcoming_page: params[:upcoming_page]
    ).call

    json_response(result)
  end

  def create
    @lesson = Lesson.new(lesson_params)
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
          id: @lesson.student.id,
          name: @lesson.student.name,
          instruments: @lesson.student.instruments
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
    lessons = Lesson.unscoped.joins(:student)
      .where(students: { user_id: current_user.id })
      .where('date_time >= ? AND date_time <= ?', start_date, end_date)
      .order(:date_time)

    result = lessons.map do |lesson|
      {
        id: lesson.id,  
        student: { id: lesson.student.id, name: lesson.student.name },
        date_time: lesson.date_time,
        duration: lesson.duration
      }
    end   
    json_response(result)
  end

  private

  def lesson_params
    params.require(:lesson).permit(
      :date_time, :duration, :plan, :status, :charge, :paid, :notes, :student_id
    )
  end

  def set_student
    @student = current_user.students.unscoped.find_by(id: params[:student_id])
  end

  def set_lesson
    @lesson = Lesson.unscoped.find(params[:id])
  end
end
