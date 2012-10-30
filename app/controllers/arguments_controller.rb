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

    if @argument.save
      flash[:success] =  'Argument was successfully added.'
      redirect_to @page
    else
      render action: "new"
    end
  end

private
  def current_page
    Page.find(params[:page_id])
  end
end
