class UsersController < ApplicationController # :nodoc:
  def new
    @user = User.new
  end

  def create
    user_params = params.require(:user).permit(:first_name, :last_name, :email, :password, :address)
    # @user = User.create user_params - before invalid testing
    @user = User.new user_params
    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: "account created!"
    else
      render :new
    end
  end
end
