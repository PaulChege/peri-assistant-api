class BreakSerializer
  def initialize(break_record)
    @break = break_record
  end

  def as_json(*_args)
    @break.as_json(
      only: [:id, :start_date, :end_date, :breakable_type, :breakable_id, :user_id, :created_at, :updated_at]
    ).merge(
      'break_by' => break_by
    )
  end

  private

  def break_by
    case @break.breakable
    when User
      "Myself"
    when Institution
      @break.breakable.name
    when Student
      @break.breakable.name
    else
      "Unknown"
    end
  end
end 