# frozen_string_literal: true
require "AfricasTalking"

class StudentsController < ApplicationController
  before_action :set_student, only: %i[show update destroy send_payment_reminders]

  def index
    @students = current_user.students.search(params[:query])
    json_response(@students)
  end

  def create
    # TODO: Move student creation to a service
    institution = Institution.find_or_create_by(name: student_params[:institution] || 'Other')
    @student = current_user.students.new(
      student_params.except(:institution).merge(institution_id: institution.id)
    )
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
    unpaid_lessons = @student.lessons.order('date_time ASC').where(paid: false)
    if unpaid_lessons.empty?
      json_response({message: 'Student has no unpaid lessons'}, :unprocessable_entity)
      return
    end
    unpaid_lessons_text = unpaid_lessons.map{|l| "#{l.date_time.strftime("%B %d, %Y at %H:%M")} -> #{l.charge}"}.join(',')
    message = "Hello, please make payments for the following lessons:\n\n#{unpaid_lessons_text}\nTOTAL = #{unpaid_lessons.sum(:charge)}\n\nThank you, #{@current_user.name}."
    SmsService.new(@student.mobile_number, message).send_sms
    json_response({message: 'Reminders sent'}, :ok)
  rescue AfricasTalking::AfricasTalkingException, StandardError => ex
    json_response({message: ex}, :unprocessable_entity)
  end

  private

  def student_params
    # whitelist params
    params.require(:student)
          .permit(:id, :name, :email, :institution,
                  :instruments, :start_date, :lesson_unit_charge,
                  :goals, :mobile_number, :date_of_birth, schedule: [:day, :start_time, :duration])
  end

  def set_student
    @student = current_user.students.find(params[:id] || params[:student_id])
  end
end
