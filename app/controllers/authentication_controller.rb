# frozen_string_literal: true
require 'json'
class AuthenticationController < ApplicationController

  skip_before_action :authorize_request

  def authenticate_google      
    user = User.find_by(email: params[:email])
 
    if user.present? && user.google_id.present?
      render json: {
        token: JsonWebToken.encode(user_id: user.id),
        user: user
      }
    elsif user.present? && user.google_id.nil?
      raise(ExceptionHandler::AuthenticationError, Message.invalid_credentials)
    elsif user.nil?
      user = User.new(
        name: params[:name],
        email: params[:email], 
        password: SecureRandom.random_number(100000..999999).to_s, 
        google_id: params[:google_id],
        google_photo_url: params[:image_url]
      )
      user.set_country_and_currency_from_ip(auth_params[:ip_address])
      if user.save
        render json: {
          token: JsonWebToken.encode(user_id: user.id),
          user: user
        }
      else
        raise(ExceptionHandler::AuthenticationError, user.errors.full_messages.join(', '))
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
    params.permit(:email, :password, :ip_address)
  end

  def set_headers
    headers['access-token'] = JsonWebToken.encode(user_id: user.id)
    headers['uid'] =@user.uid             
  end                                          
end
