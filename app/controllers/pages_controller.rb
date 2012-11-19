class PagesController < ApplicationController
  # GET /pages
  def index
    @pages = Page.all
  end

  # GET /pages/1
  def show
    @page = Page.find(params[:id])
  end

  # GET /pages/new
  def new
    @page = Page.new
  end

  # GET /pages/1/edit
  def edit
    @page = Page.find(params[:id])
  end

  # POST /pages
  def create
    @page = Page.new(params[:page])

    if @page.save
      flash[:success] =  'Page was successfully created.'
      redirect_to @page
    else
      render action: "new"
    end
  end

  # PUT /pages/1
  def update
    @page = Page.find(params[:id])

    if @page.update_attributes(params[:page])
      flash[:success] = 'Page was successfully updated'
      redirect_to @page
    else
      render action: "edit"
    end
  end

  # DELETE /pages/1
  def destroy
    @page = Page.find(params[:id])
    @page.destroy

    redirect_to pages_url
  end
end
