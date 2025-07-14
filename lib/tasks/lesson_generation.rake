# lib/tasks/lesson_generation.rake
namespace :lessons do
  desc 'Generate upcoming lessons for all students (to be run daily by cron)'
  task generate_daily: :environment do
    puts "[#{Time.now}] Starting daily lesson generation..."
    Student.find_each do |student|
      begin
        LessonGenerationService.new(student).generate_upcoming_lessons!
        puts "Generated lessons for student ##{student.id} (#{student.name})"
      rescue => e
        puts "Error generating lessons for student ##{student.id}: #{e.message}"
      end
    end
    puts "[#{Time.now}] Lesson generation complete."
  end
end 