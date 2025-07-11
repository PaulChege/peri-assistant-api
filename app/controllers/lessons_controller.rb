# frozen_string_literal: true

class LessonsController < ApplicationController
  before_action :set_student
  before_action :set_lesson, only: %i[update destroy show]

  def index
    LessonGenerationService.new(@student).generate_upcoming_lessons!
    @lessons = @student.lessons.order(day: :desc)
    json_response(@lessons)
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
    json_response(@lesson)
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

  private

  def lesson_params
    params.require(:lesson).permit(
      :day, :time, :duration, :plan, :status, :charge, :paid
    )
  end

  def set_student
    @student = current_user.students.find(params[:student_id])
  end

  def set_lesson
    @lesson = @student.lessons.find(params[:id])
  end
end
