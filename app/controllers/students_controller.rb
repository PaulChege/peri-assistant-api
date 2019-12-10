# frozen_string_literal: true

class StudentsController < ApplicationController
  before_action :set_student, only: %i[show update destroy]

  def index
    @students = current_user.students
    json_response(@students)
  end

  def create
    @student = current_user.students.new(student_params)
    if @student.valid?
      @student.save!
      json_response(@student, :created)
    else
      response = { message: @student.errors.full_messages.join(", ") }
      json_response(response, :unprocessable_entity)
    end

    rescue ActionController::ParameterMissing => e
      json_response({message: "Kindly fill in student details"}, :unprocessable_entity)
  end

  def show
    json_response(@student)
  end

  def update
    @student.assign_attributes(student_params)
    if @student.valid?
      @student.save!
      json_response(@student)
    else
      response = { message: @student.errors.full_messages.join(', ') }
      json_response(response, :unprocessable_entity)
    end
  end

  def destroy
    @student.destroy
    response = { message: 'Student succesfully deleted.' }
    json_response(response)
  end

  def all_instruments
    json_response(Student.all_instruments.sort)
  end

  private

  def student_params
    # whitelist params
    params.require(:student)
          .permit(:id, :name, :email, :institution,
                  :instrument, :start_date, :lesson_day,
                  :lesson_time, :goals, :mobile_number, :date_of_birth)
  end

  def set_student
    @student = Student.find(params[:id])
  end
end
