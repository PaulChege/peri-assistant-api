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

    # Update all future lessons with the current lesson_unit_charge
    now = Time.now.utc
    @student.lessons.where('date_time >= ?', now).find_each do |lesson|
      new_charge = (@student.lesson_unit_charge * (lesson.duration.to_f / 30.0)).round
      lesson.update(charge: new_charge)
    end

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

          # Combine date and time into a single DateTime
          date_time = DateTime.parse("#{date} #{entry['start_time']}")
          # Skip creation if date_time is in the past
          next if date_time < Time.now.utc
          scheduled_lessons << { date_time: date_time }

          # Find lesson on this date_time
          lesson = @student.lessons.find_by(date_time: date_time)
          if lesson
            # If duration or charge is different, update it
            updates = {}
            updates[:duration] = entry['duration'] if lesson.duration != entry['duration']
            updates[:charge] = @student.lesson_unit_charge if lesson.charge != @student.lesson_unit_charge
            lesson.update(updates) if updates.any?
          else
            # Create lesson if it doesn't exist
            calculated_charge = (@student.lesson_unit_charge * (entry['duration'].to_f / 30.0)).round
            @student.lessons.create(
              date_time: date_time,
              duration: entry['duration'],
              charge: calculated_charge,
              status: nil,
              paid: false
            )
          end
        end
      end

      # Delete lessons in this week that are not part of the schedule
      week_start = week_dates.first.beginning_of_day
      week_end = week_dates.last.end_of_day
      week_lessons = @student.lessons.where(date_time: week_start..week_end)
      week_lessons.each do |lesson|
        next if lesson.date_time < Time.now.utc
        unless scheduled_lessons.any? { |sl| sl[:date_time] == lesson.date_time }
          lesson.destroy
        end
      end
    end
  end
end 