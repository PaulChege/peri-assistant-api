FactoryBot.define do
  factory :break do
    start_date { Date.today + 1.week }
    end_date { Date.today + 2.weeks }
    association :user
    
    trait :for_student do
      association :breakable, factory: :student
    end
    
    trait :for_institution do
      association :breakable, factory: :institution
    end
    
    trait :for_user do
      association :breakable, factory: :user
    end
    
    trait :active do
      start_date { Date.today - 1.week }
      end_date { Date.today + 1.week }
    end
    
    trait :inactive do
      start_date { Date.today - 2.weeks }
      end_date { Date.today - 1.week }
    end
    
    trait :current do
      start_date { Date.today - 1.day }
      end_date { Date.today + 1.day }
    end
  end
end 