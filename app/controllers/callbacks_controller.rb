class CallbacksController < ApplicationController # :nodoc:
  def twitter
    render json: request.env['omniauth.auth']
  end
end
