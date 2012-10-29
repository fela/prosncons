class SessionsController < ApplicationController
  def new
  end
  def create
    login_info = params[:login]
    #p login_info
    user = User.authenticate(login_info[:name], login_info[:password])
    if user
      session[:username] = user.name
      session[:user_id] = user.id
      flash[:success] = 'Logged in!'
      redirect_to root_url
    else
      flash[:error] = 'Invalid username or password'
      render "new"
    end
  end
  def destroy
    session[:username] = nil
    flash[:info] = 'Logged out'
    redirect_to root_path
  end
end
