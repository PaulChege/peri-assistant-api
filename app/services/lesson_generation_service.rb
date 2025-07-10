# frozen_string_literal: true

class LessonGenerationService
  # Generates lessons for a student based on their schedule for the next 12 weeks
  # Only creates lessons that do not already exist
  def initialize(student)
    @student = student
  end

  def generate_upcoming_lessons!
    schedule = @student.schedule || []
    return if schedule.empty?

    start_date = Date.today.beginning_of_week(:monday)
    end_date = start_date + 11.weeks + 6.days # 12 weeks from now, inclusive

    # Map weekday names to numbers (Monday = 1, Sunday = 0)
    weekday_map = {
      'sunday' => 0, 'monday' => 1, 'tuesday' => 2, 'wednesday' => 3,
      'thursday' => 4, 'friday' => 5, 'saturday' => 6
    }

    (start_date..end_date).each_slice(7) do |week_dates|
      # For each week, build the set of scheduled lessons for that week
      scheduled_lessons = []
      week_dates.each do |date|
        schedule.each do |entry|
          schedule_day = entry['day']&.downcase
          next unless weekday_map[schedule_day] == date.wday

          scheduled_lessons << { day: date, time: entry['start_time'] }

          # Find lesson on this day
          lesson = @student.lessons.find_by(day: date)
          if lesson
            # If time is different, update it
            if lesson.time.strftime('%H:%M') != entry['start_time']
              lesson.update(time: entry['start_time'])
            end
          else
            # Create lesson if it doesn't exist
            @student.lessons.create(
              day: date,
              time: entry['start_time'],
              duration: entry['duration'],
              charge: @student.lesson_unit_charge,
              status: nil,
              paid: false
            )
          end
        end
      end

      # Delete lessons in this week that are not part of the schedule
      week_lessons = @student.lessons.where(day: week_dates)
      week_lessons.each do |lesson|
        unless scheduled_lessons.any? { |sl| sl[:day] == lesson.day && lesson.time.strftime('%H:%M') == sl[:time] }
          lesson.destroy
        end
      end
    end
  end
end 