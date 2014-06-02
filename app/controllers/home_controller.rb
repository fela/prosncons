class HomeController < ApplicationController
  def index
    @recent_arguments = Argument.order(created_at: :desc).limit(5)
  end
  def test
    render text: 'test'
  end
  def faq
  end
end
