class StudentsController < ApplicationController
  before_action :set_student, only: [:show, :update, :destroy]

  # GET /students
  def index
    @students = current_user.students
    json_response(@students)
  end

  # POST /students
  def create
    puts student_params
    @student = current_user.students.create!(student_params)
    json_response(@student, :created)
  end

  # GET /students/:id
  def show
    json_response(@student)
  end

  # PUT /students/:id
  def update
    @student.update(todo_params)
    head :no_content
  end

  # DELETE /students/:id
  def destroy
    @student.destroy
    head :no_content
  end

  private

  def student_params
    # whitelist params
    params.permit(:name, :institution, :mobile_number)
  end

  def set_student
    @student = Student.find(params[:id])
  end
end