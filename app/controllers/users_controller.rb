# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :authorize_request, only: :create

  # POST /signup
  # return authenticated token upon signup
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
      response = { message: user.errors.full_messages.join(", ") }
      json_response(response, 422)
    end
  end

  private

  def user_params
    params.permit(
      :name,
      :email,
      :password,
      :password_confirmation
    )
  end
end
