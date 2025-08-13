# frozen_string_literal: true

require 'will_paginate/active_record'

class ReportFilterService
  def initialize(base, page: 1, per_page: 10, start_date: nil, end_date: nil)
    @base = base
    @page = page
    @per_page = per_page
    @start_date = start_date
    @end_date = end_date
  end

  def call
    reports = filtered_reports.paginate(page: page, per_page: per_page)
    
    {
      reports: reports.map { |report| ReportSerializer.new(report).as_json },
      current_page: reports.current_page,
      total_pages: reports.total_pages,
      total_entries: reports.total_entries,
      metadata: build_metadata
    }
  end

  private

  attr_reader :base, :page, :per_page, :start_date, :end_date

  def filtered_reports
    reports = if base.is_a?(Student)
                base.reports.order(created_at: :desc)
              else
                Report.joins(:student).where(students: { user_id: base.id }).order(created_at: :desc)
              end
    
    # Filter by date range if provided
    if start_date.present? && end_date.present?
      reports = reports.by_date_range(start_date, end_date)
    end
    
    reports
  end

  def build_metadata
    if base.is_a?(Student)
      {
        student: {
          id: base.id,
          name: base.name,
          instruments: base.instruments
        }
      }
    else
      {
        user: {
          id: base.id,
          name: base.name
        }
      }
    end
  end
end
