class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def authenticate_user!
    redirect_to new_user_path unless user_signed_in?
  end

  def user_signed_in?
    session[:user_id].present?
  end

end
