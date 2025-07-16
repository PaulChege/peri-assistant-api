class StudentSerializer
  def initialize(student)
    @student = student
  end

  def as_json(*_args)
    @student.as_json(
        only: [:id, :name, :mobile_number, :email, :instruments, :schedule, :lesson_unit_charge]
      ).merge(
      'institution' => {
        'name' => @student.institution&.name
      }
    )
  end
end 