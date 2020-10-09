# frozen_string_literal: true

class StudentsController < ApplicationController
  before_action :set_student, only: %i[show update destroy send_payment_reminders]

  def index
    @students = current_user.students.search(params[:query])
    json_response(@students)
  end

  def create
    @student = current_user.students.new(student_params)
    if @student.valid?
      @student.save!
      json_response(@student, :created)
    else
      response = { message: @student.errors.full_messages.join(', ') }
      json_response(response, :unprocessable_entity)
    end
  rescue ActionController::ParameterMissing => e
    json_response({ message: 'Kindly fill in student details' }, :unprocessable_entity)
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

  def send_payment_reminders
    # Respond with error message if student has no unpaid lessons
    unpaid_lessons = @student.lessons.order('day ASC, time ASC').where(paid: false)
    unpaid_lessons_text = unpaid_lessons.map{|l| "#{l.day.strftime("%B %d, %Y")} at #{l.time.strftime("%I:%M")} -> #{l.charge}"}.join(',')
    message = "Hello, please make payments for the following lessons:\n\n#{unpaid_lessons_text}\nTOTAL = #{unpaid_lessons.sum(:charge)}\n\nThank you, #{@current_user.name}."
    puts message

    # SEND USING AT
  end

  private

  def student_params
    # whitelist params
    params.require(:student)
          .permit(:id, :name, :email, :institution,
                  :instrument, :start_date, :lesson_day,
                  :lesson_time, :lesson_duration, :lesson_charge,
                  :goals, :mobile_number, :date_of_birth)
  end

  def set_student
    @student = current_user.students.find(params[:id] || params[:student_id])
  end
end
