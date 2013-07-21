class ArgumentsController < ApplicationController

  def new
    @argument = Argument.new()
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
    @argument = Argument.find(params[:id])
  end

  def update
    @argument = Argument.find(params[:id])
    authorize! :update, @argument

    if @argument.update_attributes(params[:argument])
      flash[:success] = 'Argument was successfully updated'
      redirect_to current_page
    else
      render action: "edit"
    end
  end

private
  def current_page
    Page.find(params[:page_id])
  end
end
