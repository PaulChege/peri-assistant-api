# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :authorize_request, only: :create
  before_action :get_user, except: :create

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
      response = { message: user.errors.full_messages.join(', ') }
      json_response(response, 422)
    end
  end

  def update
    @user.assign_attributes(user_params)
    if @user.valid?
      @user.save!
      json_response(@user)
    else
      response = { message: @user.errors.full_messages.join(', ') }
      json_response(response, 422)
    end
  end

  def destroy
    @user.delete
    response = { message: 'Account succesfully deleted.' }
    json_response(response)
  end

  private

  def get_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :name,
      :email,
      :password,
      :password_confirmation
    )
  end
end
