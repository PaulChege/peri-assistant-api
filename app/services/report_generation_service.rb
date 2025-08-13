# frozen_string_literal: true

require 'ruby_llm'

class ReportGenerationService
  def initialize(student, start_date, end_date)
    @student = student
    @start_date = start_date
    @end_date = end_date
  end

  def call
    lessons_data = fetch_lessons_data
    return { error: 'No lessons found for the specified period' } if lessons_data.empty?

    generate_report(lessons_data)
  end

  private

  attr_reader :student, :start_date, :end_date

  def fetch_lessons_data
    student.lessons
          .where('date_time >= ? AND date_time <= ?', start_date.beginning_of_day, end_date.end_of_day)
          .order(:date_time)
          .pluck(:date_time, :plan, :notes)
          .reject { |lesson| lesson[1].blank? && lesson[2].blank? }
  end

  def generate_report(lessons_data)
    prompt = build_prompt(lessons_data)
    
    # Create a chat instance using RubyLLM
    chat = RubyLLM.chat
    
    # Ask for the report
    response = chat.ask(prompt)

    {
      summary: response.content,
      lessons_count: lessons_data.length,
      period: "#{start_date.strftime('%B %d, %Y')} - #{end_date.strftime('%B %d, %Y')}"
    }
  rescue => e
    Rails.logger.error "LLM API Error: #{e.message}"
    { error: 'Failed to generate report. Please try again.' }
  end

  def build_prompt(lessons_data)
    lesson_summaries = lessons_data.map.with_index(1) do |(date_time, plan, notes), index|
      date_str = date_time.strftime('%B %d, %Y')
      content = []
      content << "Plan: #{plan}" if plan.present?
      content << "Notes: #{notes}" if notes.present?
      
      "Lesson #{index} (#{date_str}): #{content.join(' | ')}"
    end.join("\n\n")

    <<~PROMPT
      Generate a 100-150 word professional report summary for #{student.name} based on the following lesson data:

      Student: #{student.name}
      Instruments: #{student.instruments}
      Period: #{start_date.strftime('%B %d, %Y')} - #{end_date.strftime('%B %d, %Y')}

      Lesson Details:
      #{lesson_summaries}

      Please provide a concise summary that:
      - Highlights key progress areas
      - Mentions any challenges or achievements
      - Provides constructive feedback
      - Maintains a professional tone
      - Is between 100-150 words
    PROMPT
  end
end
