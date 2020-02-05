# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string
#  email           :string
#  password_digest :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class User < ApplicationRecord
  # encrypt password
  has_secure_password

  # Model associations
  has_many :students, dependent: :delete_all

  has_many :lessons, through: :students
  # Validations
  validates_presence_of :name, :email, :password_digest
  validates :email, uniqueness: true
end
