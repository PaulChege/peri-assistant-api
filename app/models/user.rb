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

  def self.create_user_for_google(data)                  
    where(uid: data["email"]).first_or_initialize.tap do |user|
      user.provider="google_oauth2"
      user.uid=data["email"]
      user.email=data["email"]
      user.password = data['email']
      user.password_confirmation=user.password
      user.save!
    end
  end  
end
