module PagesHelper
  def base_argument_path(page, option)
    "/pages/#{page.id}/arguments/#{option}"
  end
  def new_argument_path(page, option)
    base_argument_path(page, option) + '/new'
  end
  def edit_argument_path(argument)
    base_argument_path(argument.page, argument.option) + "/#{argument.id}/edit"
  end
  def update_argument_path(argument)
    base_argument(path(argument.page, argument.option))
  end
  def versions_argument_path(argument)
    base_argument_path(argument.page, argument.option) +
        "/#{argument.id}/versions"
  end
  def versions_path(obj)
    if obj.is_a? Argument
      versions_argument_path(obj)
    elsif obj.is_a? Page
      versions_page_path(obj)
    else
      '#'
    end
  end
  def update_or_create_path(argument)
    unless argument.is_a? Argument
      raise ArgumentError.new('argument must be of class Argument')
    end
    page = argument.page
    option = argument.option
    puts option.inspect
    if argument.new_record?
      url = base_argument_path(page, option)
      method = :post
    else
      url = page_argument_path(page, argument)
      method = :put
    end
    {url: url, method: method}
  end
end
