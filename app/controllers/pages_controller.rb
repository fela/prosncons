class PagesController < ApplicationController
  load_and_authorize_resource

  # GET /pages
  def index
  end

  # GET /pages/1
  def show
  end

  # GET /pages/new
  def new
  end

  # GET /pages/1/edit
  def edit
  end

  # POST /pages
  def create
    @page.user = @logged_in_user
    if @page.save
      flash[:success] =  'Page was successfully created.'
      redirect_to @page
    else
      render action: "new"
    end
  end

  # PUT /pages/1
  def update
    if @page.update_attributes(params[:page])
      flash[:success] = 'Page was successfully updated'
      redirect_to @page
    else
      render action: "edit"
    end
  end

  # DELETE /pages/1
  def destroy
    @page.destroy

    redirect_to pages_url
  end
end
