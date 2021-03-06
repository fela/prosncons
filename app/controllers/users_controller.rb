class UsersController < ApplicationController
  # GET /users
  def index
    # TODO: change when reputation will be denormalized
    @users = User.all.to_a.sort_by!(&:reputation).reverse
  end

  # GET /users/1
  def show
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    raise ActionController::RoutingError.new('Not Found')
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update_attributes(params[:user])
      flash[:success] = 'Your profile was successfully updated'
      redirect_to @user
    else
      render action: 'edit'
    end
  end
end
