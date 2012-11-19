class UsersController < ApplicationController
  # GET /users
  def index
    @users = User.all
  end

  # GET /users/1
  def show
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    raise ActionController::RoutingError.new('Not Found')
  end

  # POST /users
  #def create
  #  @user = User.new(params[:user])
  #  if @user.save
  #    flash[:success] = 'User was successfully created.'
  #    redirect_to root_path
  #  else
  #    render :new
  #  end
  #end
end
