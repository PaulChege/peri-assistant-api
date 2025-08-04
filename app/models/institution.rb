class Institution < ApplicationRecord
  has_many :students, dependent: :destroy
  has_many :breaks, as: :breakable, dependent: :destroy
end
