module ApplicationHelper
  def glyph(*names)
    content_tag :i, nil, class: names.map do |name|
      "icon-#{name.to_s.gsub('_','-')}"
    end
  end
end
