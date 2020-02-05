# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :authorize_request, only: :create

  def show
    json_response(current_user)
  end
  
  def create
    user = User.new(user_params)
    if user.valid?
      user.save!
      authUser = AuthenticateUser.new(user.email, user.password).call
      response = {
        message: Message.account_created,
        user: user,
        token: authUser[:token]
      }
      json_response(response)
    else
      response = { message: user.errors.full_messages.join(', ') }
      json_response(response, 422)
    end
  end

  def update
    current_user.assign_attributes(user_params)
    if current_user.valid?
      current_user.save!
      json_response(current_user)
    else
      response = { message: current_user.errors.full_messages.join(', ') }
      json_response(response, 422)
    end
  end

  def destroy
    current_user.destroy
    response = { message: 'Account succesfully deleted.' }
    json_response(response)
  end

  private

  def user_params
    params.require(:user).permit(
      :name,
      :email,
      :password,
      :password_confirmation
    )
  end
end
