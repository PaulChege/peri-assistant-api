class StudentsController < ApplicationController
  before_action :set_student, only: [:show, :update, :destroy]

  # GET /students
  def index
    @students = current_user.students
    json_response(@students)
  end

  # POST /students
  def create
    @student = current_user.students.create!(student_params)
    json_response(@student, :created)
  end

  # GET /students/:id
  def show
    json_response(@student)
  end

  # PUT /students/:id
  def update
    @student.assign_attributes(student_params)
    if @student.valid? 
      @student.save!
      json_response(current_user.students)
    else
      response = { message: @student.errors.full_messages.join(',')}
      json_response(response, :error)
    end
  end

  # DELETE /students/:id
  def destroy
    @student.destroy
    json_response(current_user.students)
  end

  def all_instruments
    json_response(Student.all_instruments.sort)
  end

  private

  def student_params
    # whitelist params
    params.require(:student).permit(:id, :name, :email, :institution, 
    :instrument, :start_date, :lesson_day, :lesson_time, :goals, :mobile_number)
  end

  def set_student
    @student = Student.find(params[:id])
  end
end