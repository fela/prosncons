module PagesHelper
  def base_argument_path(page, option)
    "/pages/#{page.id}/arguments/#{option.parameterize}"
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
    else
      '#'
    end
  end
  def update_or_create_path(argument)
    page = argument.page
    option = argument.option
    if argument.new_record?
      url = base_argument_path(page, option)
      method = :post
    else
      url = base_argument_path(page, option) + "/#{argument.id}/"
      method = :put
    end
    {url: url, method: method}
  end
end
