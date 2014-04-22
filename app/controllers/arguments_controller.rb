class ArgumentsController < ApplicationController
  load_and_authorize_resource

  def new
    @argument = Argument.new
    @page = current_page
    @argument.page = @page
    @option = params[:option]
    @argument.option = @option
  end

  def create
    @page = current_page
    @option = params[:option]
    @argument = Argument.new(params[:argument])
    @argument.option = @option
    @argument.page = @page
    @argument.user = @logged_in_user

    if @argument.save
      flash[:success] =  'Argument was successfully added.'
      redirect_to @page
    else
      render action: "new"
    end
  end

  def edit
    @argument = current_argument
  end

  def update
    @argument = current_argument
    authorize! :update, @argument

    puts 'current user:'
    puts current_user
    if @argument.update_attributes(params[:argument])
      flash[:success] = 'Argument was successfully updated'
      redirect_to current_page
    else
      render action: "edit"
    end
  end

  def vote
    argument = current_argument
    argument.vote(user: @logged_in_user, vote_type: params[:vote_type])
    render text: (argument.score * 10).round(1)
  end

  def versions
    @argument = current_argument
  end

private
  def current_page
    Page.find(params[:page_id])
  end
  def current_argument
    Argument.find(params[:id])
  end
end
