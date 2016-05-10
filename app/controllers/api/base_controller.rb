class Api::BaseController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_user

  private

  def authenticate_user
    @user = User.find_by_api_key params[:api_key]
    head :forbidden unless @user
  end
end
