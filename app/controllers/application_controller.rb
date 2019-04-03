class ApplicationController < ActionController::API
  before_action :authorize_request
  attr_reader :current_user

  include Response
  include ExceptionHandler


   # called before every action on controllers
 
   private
 
   # Check for valid request token and return user
   def authorize_request
     @current_user = (AuthorizeApiRequest.new(request.headers).call)[:user]
   end
end
