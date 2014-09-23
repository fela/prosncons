class CommentsController < ApplicationController
  load_and_authorize_resource

  def index
  end

  def show
  end

  def new
    @comment = Comment.new
    set_about
  end

  def edit
  end

  def create
    @comment.user = @logged_in_user
    set_about
    if @comment.save
      flash[:success] = 'Your comment was successfully added.'
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

  private def set_about
    if params[:argument_id]
      @comment.about = Argument.find(params[:argument_id])
    else
      @comment.about = Page.find(params[:page_id])
    end
  end

end
