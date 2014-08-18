class VotesController < ApplicationController
  load_and_authorize_resource

  def index
  end

  def show
  end

  def new
    @comment = Comment.new
    if params[:argument_id]
      @comment.about Argument.find(params[:argument_id])
    else
      @comment.about = Page.find(params[:page_id])
    end
  end

  def edit
  end

  def create
    @comment.user = @logged_in_user
    if @comment.save
      flash[:success] =  'Page was successfully created.'
      redirect_to @comment.page
    else
      render action: 'new'
    end
  end

  def update
    if @comment.update_attributes(params[:comment])
      flash[:success] = 'Page was successfully updated'
      redirect_to @comment
    else
      render action: 'edit'
    end
  end
end
