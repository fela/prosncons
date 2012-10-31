module PagesHelper
  def base_argument_path(option=nil)
    option ||= @option
    "/pages/#{@page.id}/arguments/#{option.parameterize}"
  end
  def new_argument_path(option=nil)
    base_argument_path(option) + '/new'
  end
  def create_argument_path
    base_argument_path
  end
  def edit_argument_path(a, option)
    base_argument_path(option) + "/#{a.id}/edit"
  end
  def argument_path
    base_argument_path + "/#{@argument.id}/"
  end
  def edit_or_create_path
    if @argument.new_record?
      {url: create_argument_path, method: :post}
    else
      {url: argument_path, method: :put}
    end
  end
end
