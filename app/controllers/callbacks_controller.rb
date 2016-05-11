class CallbacksController < ApplicationController # :nodoc:
  def twitter
    user = User.find_or_create_with_twitter request.env['omniauth.auth']
    session[:user_id] = user.id
    redirect_to root_path, notice: 'Thank you for signing in with Twitter'
    # render json: request.env['omniauth.auth']
  end
end
