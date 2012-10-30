module PagesHelper
  def new_argument_path(page, option)
    "/pages/#{page.id}/arguments/#{option.parameterize}/new"
  end
  def create_argument_path
    "/pages/#{@page.id}/arguments/#{@option.parameterize}"
  end
end
