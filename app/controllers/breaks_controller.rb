class BreaksController < ApplicationController
  before_action :set_break, only: [:update, :destroy]

  def index
    breaks = Break.where(user_id: current_user.id).where('end_date > ?', Time.now)
    json_response(breaks.map { |break_record| BreakSerializer.new(break_record).as_json })
  end

  def create
    break_record = Break.new(break_params.merge(user_id: current_user.id))
    
    if break_record.save
      json_response(break_record, :created)
    else
      json_response({ errors: break_record.errors }, :unprocessable_entity)
    end
  end

  def update
    if @break.update(break_params)
      json_response(@break)
    else
      json_response({ errors: @break.errors }, :unprocessable_entity)
    end
  end

  def destroy
    if @break.destroy
      head :no_content
    else
      json_response({ errors: @break.errors }, :unprocessable_entity)
    end
  end

  def user_students
    students = current_user.students.select(:id, :name).order(:name)
    json_response(students.map { |student| { id: student.id, name: student.name } })
  end

  def user_institutions
    institutions = current_user.students.joins(:institution)
                              .select('institutions.id, institutions.name')
                              .distinct
                              .order('institutions.name')
    json_response(institutions.map { |institution| { id: institution.id, name: institution.name } })
  end

  private

  def set_break
    @break = Break.find_by(id: params[:id], user_id: current_user.id)
  end

  def break_params
    params.require(:break).permit(:start_date, :end_date, :breakable_type, :breakable_id)
  end
end 