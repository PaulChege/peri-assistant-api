# frozen_string_literal: true
require 'json'
class AuthenticationController < ApplicationController
  include HTTParty

  skip_before_action :authorize_request, :authenticate_google

  def authenticate_google      
    user = User.where(email: params[:email])
    if user.present? && user.google_id.present?
      render json: {
        token: JsonWebToken.encode(user_id: user.id),
        user: user
      }
    elsif user.present? && !user.google_id.present?
      raise(ExceptionHandler::AuthenticationError, Message.invalid_credentials)
    elsif !user.present?
      user = User.new(
        email: params[:email], 
        password: SecureRandom.random_number(100000..999999), 
        google_id: params[:google_id],
        google_photo_url: params[:image_url]
      )
      if user.save
        render json: {
          token: JsonWebToken.encode(user_id: user.id),
          user: user
        }
      else
        raise(ExceptionHandler::AuthenticationError, Message.invalid_credentials)
      end
    end
  end 

  def authenticate
    response =
      AuthenticateUser.new(auth_params[:email], auth_params[:password]).call
    json_response(response)
  end

  private

  def auth_params
    params.permit(:email, :password)
  end

  def set_headers
    headers['access-token'] = JsonWebToken.encode(user_id: user.id)
    headers['uid'] =@user.uid             
  end                                          
end
