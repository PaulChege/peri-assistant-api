class LessonsController < ApplicationController
  before_action :set_student
  before_action :set_lesson, only: [:update, :destroy]

  def index
    @lessons = @student.lessons
    json_response(@lessons)
  end

  def create
    @lesson = @student.lessons.create!(lesson_params)
    json_response(@lesson, :created)
  end

  def update
    @lesson.assign_attributes(lesson_params)
    if @lesson.valid?
      @lesson.save!
      json_response(@lesson)
    else
      response = { message: @lesson.errors.full_messages.join(',')}
      json_response(response, :error)
    end
  end

  def destroy
    @lesson.destroy
    json_response(@student.lessons)
  end

  private
    def lesson_params
      params.require(:lesson).permit(:time, :duration)
    end

    def set_student
      @student = Student.find(params[:student_id])
    end

    def set_lesson
      @lesson = Lesson.find(params[:id])
    end
end
