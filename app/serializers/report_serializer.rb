# frozen_string_literal: true

class ReportSerializer
  def initialize(report)
    @report = report
  end

  def as_json(*_args)
    @report.as_json(
      only: [:id, :summary, :start_date, :end_date, :created_at, :updated_at]
    ).merge(
      'student' => {
        'id' => @report.student.id,
        'name' => @report.student.name,
        'instruments' => @report.student.instruments
      }
    )
  end
end
