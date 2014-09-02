# config/initializers/markdown.rb

module Haml::Filters::SafeMarkdown
  include Haml::Filters::Base

  def render(text)
    ::RDiscount.new(text, :filter_html).to_html
  end

  private
  def create_renderer

  end
end

