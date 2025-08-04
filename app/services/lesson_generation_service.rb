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

    user_breaks = fetch_user_breaks
    update_existing_future_lessons
    generate_lessons_for_period(schedule, user_breaks)
    delete_lessons_within_breaks(user_breaks)
  end

  private

  def fetch_user_breaks
    return [] unless @student.user_id

    # Fetch breaks for the teacher (student's user)
    Break.where(user_id: @student.user_id)
         .where('end_date >= ?', Date.current)
         .includes(:breakable)
  end

  def update_existing_future_lessons
    now = Time.now.utc
    @student.lessons.where('date_time >= ?', now).find_each do |lesson|
      new_charge = calculate_lesson_charge(lesson.duration)
      lesson.update(charge: new_charge)
    end
  end

  def generate_lessons_for_period(schedule, user_breaks)
    start_date = Date.today.beginning_of_week(:monday)
    end_date = start_date + 11.weeks + 6.days # 12 weeks from now, inclusive

    (start_date..end_date).each_slice(7) do |week_dates|
      process_week_lessons(week_dates, schedule, user_breaks)
    end
  end

  def process_week_lessons(week_dates, schedule, user_breaks)
    scheduled_lessons = []
    
    week_dates.each do |date|
      process_day_lessons(date, schedule, user_breaks, scheduled_lessons)
    end

    cleanup_unscheduled_lessons(week_dates, scheduled_lessons)
  end

  def process_day_lessons(date, schedule, user_breaks, scheduled_lessons)
    schedule.each do |entry|
      next unless lesson_scheduled_for_day?(date, entry)

      date_time = build_lesson_datetime(date, entry)
      next if lesson_in_past?(date_time) || lesson_falls_within_break?(date_time, user_breaks)

      scheduled_lessons << { date_time: date_time }
      create_or_update_lesson(date_time, entry)
    end
  end

  def lesson_scheduled_for_day?(date, entry)
    weekday_map = {
      'sunday' => 0, 'monday' => 1, 'tuesday' => 2, 'wednesday' => 3,
      'thursday' => 4, 'friday' => 5, 'saturday' => 6
    }
    
    schedule_day = entry['day']&.downcase
    weekday_map[schedule_day] == date.wday
  end

  def build_lesson_datetime(date, entry)
    DateTime.parse("#{date} #{entry['start_time']}")
  end

  def lesson_in_past?(date_time)
    date_time < Time.now.utc
  end

  def lesson_falls_within_break?(lesson_date_time, user_breaks)
    lesson_date = lesson_date_time.to_date
    
    user_breaks.any? do |break_record|
      lesson_date >= break_record.start_date && lesson_date <= break_record.end_date
    end
  end

  def create_or_update_lesson(date_time, entry)
    lesson = @student.lessons.find_by(date_time: date_time)
    
    if lesson
      update_existing_lesson(lesson, entry)
    else
      create_new_lesson(date_time, entry)
    end
  end

  def update_existing_lesson(lesson, entry)
    updates = {}
    updates[:duration] = entry['duration'] if lesson.duration != entry['duration']
    updates[:charge] = @student.lesson_unit_charge if lesson.charge != @student.lesson_unit_charge
    lesson.update(updates) if updates.any?
  end

  def create_new_lesson(date_time, entry)
    calculated_charge = calculate_lesson_charge(entry['duration'])
    @student.lessons.create(
      date_time: date_time,
      duration: entry['duration'],
      charge: calculated_charge,
      status: nil,
      paid: false
    )
  end

  def calculate_lesson_charge(duration)
    (@student.lesson_unit_charge * (duration.to_f / 30.0)).round
  end

  def cleanup_unscheduled_lessons(week_dates, scheduled_lessons)
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

  def delete_lessons_within_breaks(user_breaks)
    return if user_breaks.empty?

    # Get all future lessons for the student
    future_lessons = @student.lessons.where('date_time >= ?', Time.now.utc)
    
    lessons_to_delete = future_lessons.select do |lesson|
      lesson_falls_within_break?(lesson.date_time, user_breaks)
    end

    # Delete lessons that fall within break periods
    lessons_to_delete.each(&:destroy)
  end
end 