module LoginHelper

  def login(user)
    request.session[:user_id] = user.id
  end

end
