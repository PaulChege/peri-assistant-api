# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :set_report, only: [:show, :update, :destroy]
  before_action :authorize_user

  def index
    if params[:student_id].present?
      # Get reports for a specific student
      student = current_user.students.find(params[:student_id])
      result = ReportFilterService.new(
        student,
        page: params[:page] || 1,
        per_page: params[:per_page] || 10,
        start_date: params[:start_date],
        end_date: params[:end_date]
      ).call
    else
      # Get reports for all students of the current user
      result = ReportFilterService.new(
        current_user,
        page: params[:page] || 1,
        per_page: params[:per_page] || 10,
        start_date: params[:start_date],
        end_date: params[:end_date]
      ).call
    end

    json_response(result)
  end

  def show
    render json: ReportSerializer.new(@report).as_json
  end

  def create
    @report = Report.new(report_params)
    if @report.save
      render json: ReportSerializer.new(@report).as_json, status: :created
    else
      render json: { errors: @report.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @report.update(report_params)
      render json: ReportSerializer.new(@report).as_json
    else
      render json: { errors: @report.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @report.destroy
    head :no_content
  end

  def generate
    student = current_user.students.find(params[:student_id])
    start_date = Date.parse(params[:start_date])
    end_date = Date.parse(params[:end_date])

    result = ReportGenerationService.new(student, start_date, end_date).call

    if result[:error]
      render json: { error: result[:error] }, status: :unprocessable_entity
    else
      render json: result
    end
  rescue Date::Error
    render json: { error: 'Invalid date format. Use YYYY-MM-DD' }, status: :bad_request
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Student not found' }, status: :not_found
  end

  private

  def set_report
    @report = Report.find(params[:id])
  end

  def report_params
    params.require(:report).permit(:student_id, :summary, :start_date, :end_date)
  end

  def authorize_user
    # For show, update, destroy actions, check if user owns the report's student
    if @report && @report.student.user_id != @current_user.id
      render json: { error: 'Unauthorized' }, status: :unauthorized
      return
    end
  end
end
